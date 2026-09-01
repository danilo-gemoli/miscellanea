#!/bin/bash

function usage() {
    echo "Make kubeconfig tool"
    echo
    echo "TODO"
}

_kubeconfig_template='apiVersion: v1
clusters:
%s
contexts:
%s
kind: Config
preferences: {}
users:
%s'

_cluster_template='\055 cluster:
    server: %s
  name: %s'

_context_template='\055 context:
    cluster: %s
    namespace: %s
    user: %s/%s
  name: %s'

_user_template='\055 name: %s/%s
  user:
    tokenFile: %s'

function print_unified_kubeconfig() {
    local template="$1"
    local clusters=$(printf '%s\n' "$2")
    local contexts=$(printf '%s\n' "$3")
    local users=$(printf '%s\n' "$4")
    printf "$template" "$clusters" "$contexts" "$users"
}

function write_kubeconfig() {
    kubeconfig="$1"
    out_file="$2"
    [ -f "$out_file" ] && chmod 644 "$out_file"
    printf '%s\n' "$kubeconfig" >"$out_file"
    chmod 444 "$out_file"
}

function append() {
    items="$1"
    item="$2"
    [ ! -z "$items" ] && printf '%s\n%s' "$items" "$item" || printf '%s' "$item"
}

function ensure_dir() {
    dir="$1"
    if [ ! -d "$dir" ]; then
        printf '%s does not exist, creating...\n' "$dir"
        mkdir -p "$dir"
    fi
}

# Read kubeconfig configurations line by line.
# Each line matches the following pattern:
# ${USER},${CLUSTER_HOSTNAME},${CONTEXT_NAME},${NAMESPACE}
function make_kubeconfigs() {
    local output_dir="$1"
    local merge_configs=$2

    local clusters=''
    local contexts=''
    local users=''

    ensure_dir "$output_dir"

    while read line; do
        OLD_IFS=$IFS
        IFS=',' read -ra entries <<<"$line"
        IFS=$OLD_IFS

        user="${entries[0]}"
        server="${entries[1]}"
        context_name="${entries[2]}"
        namespace="${entries[3]}"

        context_name_normalized="$(printf "${entries[2]}" | sed 's/\.//g')"

        # Remove protocol (https://), port (:1234) and replace '.' with '-' 
        cluster_name=$(printf "$server" | sed -E 's|^.+\://||;s|\.|-|g;s|\:.+$||g')

        token_file="$(printf ${context_name_normalized}-token)"

        cluster=$(printf "$_cluster_template" "$server" "$cluster_name")
        context=$(printf "$_context_template" "$cluster_name" "$namespace" "$user" "$cluster_name" "$context_name")
        user=$(printf "$_user_template" "$user" "$cluster_name" "$token_file")

        if [ $merge_configs -eq 1 ]; then
            clusters=$(append "$clusters" "$cluster")
            contexts=$(append "$contexts" "$context")
            users=$(append "$users" "$user")
        else
            kubeconfig=$(printf "$_kubeconfig_template" "$cluster" "$context" "$user")
            kubeconfig_out="$output_dir/${context_name_normalized}-kubeconfig.yaml"
            write_kubeconfig "$kubeconfig" "$kubeconfig_out"
        fi

        touch "$output_dir/${context_name_normalized}-token"
    done

    if [ $merge_configs -eq 1 ]; then
        kubeconfig=$(print_unified_kubeconfig "$_kubeconfig_template" "$clusters" "$contexts" "$users")
        kubeconfig_out="$output_dir/testplatform-kubeconfig.yaml"
        write_kubeconfig "$kubeconfig" "$kubeconfig_out"
    fi
}

function validate_args() {
    if test -z "$kubeconfigs_dir"; then
        usage
        exit 1
    fi
}

kubeconfigs_dir=''
grand_kubeconfig=0

function parse_args() {
    while getopts ":huk:" o; do
        case "$o" in
            k)
                kubeconfigs_dir=${OPTARG}
                ;;
            u)
                grand_kubeconfig=1
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

make_kubeconfigs "$kubeconfigs_dir" $grand_kubeconfig
