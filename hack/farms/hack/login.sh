#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/common.sh"

function usage() {
    echo "Login tool"
    echo
    echo "This is an all-in-one tool that:"
    echo "  1. checks whether the user is logged into the Red Hat SSO, prompting for a login if he/she isn't;"
    echo "  2. logs the user into each context defined on each kubeconfig found in the provided kubeconfigs directory."
    echo
    echo "Options:"
    echo "  -k path to the kubeconfigs directory"
    echo "  -h display help"
    echo
    echo "The tool expects the kubeconfigs directory to contain files that follow the pattern:"
    echo "  \${KUBECONFIG_NAME}-kubeconfig.yaml"
    echo "  \${CLUSTER_NAME}-token"
    echo
    echo "Each context must set a '.users[].user.tokenFile' stanza referencing its respective \${CLUSTER_NAME}-token"
    echo
    echo "\$KUBECONFIGS_DIR example:"
    echo "  testplatform-kubeconfig.yaml"
    echo "  appci-token"
    echo "  build01-token"
    echo "  ..."
    echo
    echo "Kubeconfig example (build01-kubeconfig.yaml):"
    echo "  apiVersion: v1"
    echo "  clusters:"
    echo "  - cluster:"
    echo "      server: https://api.build01.ci.devcluster.openshift.com:6443"
    echo "    name: api-build01-ci-devcluster-openshift-com:6443"
    echo "  contexts:"
    echo "  - context:"
    echo "      cluster: api-build01-ci-devcluster-openshift-com:6443"
    echo "      namespace: ci"
    echo "      user: my-user/api-build01-ci-devcluster-openshift-com:6443"
    echo "    name: build01"
    echo "  current-context: build01"
    echo "  kind: Config"
    echo "  preferences: {}"
    echo "  users:"
    echo "  - name: my-user/api-build01-ci-devcluster-openshift-com:6443"
    echo "    user:"
    echo "      tokenFile: build01-token"
    echo
    echo "Cookies need to be persisted across HTTP requests to perform a proper login,"
    echo "the env. variable COOKIES defines the absolute path to the file that should hold them."
    echo
    echo "Usage example:"
    echo "  COOKIES=/tmp/cookies.txt login.sh -k \$HOME/.kube/configs"
}

kubeconfigs_dir=""

function sso_is_auth() {
    "$script_dir/sso_is_auth.sh"
}

function sso_auth() {
    "$script_dir/sso_auth.sh"
}

function cluster_is_auth() {
    kubeconfig="$1"
    context="$2"
    KUBECONFIG="$kubeconfig" "$script_dir/cluster_is_auth.sh" "$context"
}

function cluster_login() {
    context="$1"
    oauth_endpoint="$2"
    tokefile="$3"
    kubeconfig="$4"
    if ! $(cluster_is_auth "$kubeconfig" "$context"); then
        printf "Not logged on context '$context'\nLogging using '$oauth_endpoint' endpoint...\n"    
        "$script_dir/cluster_login.sh" "$oauth_endpoint" "$tokefile"
    fi
}

# Transform a kubeconfig into a stream tokens that follow the pattern:
# ${USER}
# ${TOKEN_FILE}
# ${CLUSTER}
# ${SERVER}
# ${CONTEXT}
# ---
function entries_from_kubeconfig() {
    kubeconfig="$1"
    jq -rf "$script_dir/kubeconfig-entries.jq" <(yq -ojson "$kubeconfig")
}

function clusters_login() {
    kubeconfigs_dir="$1"
    kubeconfig_names="$2"
    for kubeconfig_name in $kubeconfig_names; do
        kubeconfig="$kubeconfigs_dir/$kubeconfig_name"

        printf 'Open kubeconfig: %s\n' "$kubeconfig"
        entries_from_kubeconfig "$kubeconfig" | while read user; do
            read kubetoken; read cluster; read server; read kubecontext; read separator

            oauth_endpoint=$(printf "$server" | \
                sed -E 's|^https\://api\.|https\://oauth\-openshift\.apps\.|g; s|\:6443$||g')
            kubetoken="$kubeconfigs_dir/$kubetoken"
            
            printf "Log into cluster %s\n" "$kubecontext"
            cluster_login "$kubecontext" "$oauth_endpoint" "$kubetoken" "$kubeconfig"
        done 
    done
}

function clusters_from_configs() {
    kubeconfigs_dir="$1"
    ls -1 "$kubeconfigs_dir"|grep '\-kubeconfig.yaml'|sort|uniq
}

function login() {
    kubeconfigs_dir="$1"
    printf "Check whether the user is already logged into RH SSO\n"
    if ! $(sso_is_auth); then
        printf "User not logged into RH SSO\nAuthenticating...\n"
        sso_auth
    fi
    printf "Determine kubeconfigs from dir: '%s'\n" "$kubeconfigs_dir"
    kubeconfigs=$(clusters_from_configs "$kubeconfigs_dir")
    printf "Use the kubeconfigs: %s\n" "$(echo "$kubeconfigs"|tr '\n' ' ')"
    clusters_login "$kubeconfigs_dir" "$kubeconfigs"
}

function validate_args() {
    if test -z "$kubeconfigs_dir"; then
        usage
        exit 1
    fi
}

function parse_args() {
    while getopts ":hk:" o; do
        case "$o" in
            k)
                kubeconfigs_dir=${OPTARG}
                ;;
            h)
                usage
                exit 0
                ;;
            *)
                usage
                exit 1
                ;;
        esac
    done
}

parse_args $@
shift $((OPTIND-1))    
validate_args
login "$kubeconfigs_dir"
