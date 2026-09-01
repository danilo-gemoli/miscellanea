#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/common.sh"

# Step 1
# Head over oauth/token/request
# Expect to be redirected to the RH SSO Login page
# Click on 'Login using RH SSO'
function cluster_token_request() {
    base="$1"
    url_token_request="$base/oauth/token/request"
    CURL -b "$COOKIES" -c "$COOKIES" -L "$url_token_request"
    curl_expect_200
    redhat_sso=$(curl_output | html_read_attr 'href' 'body main a[title~="RedHat_Internal_SSO"]')

    # CoreCI cluster doesn't have `RedHat_Internal_SSO`
    if [ $? -ne 0 ]; then
        redhat_sso=$(curl_output | html_read_attr 'href' 'body main a[title~="RedHat_Internal"]')
    fi

    redhat_sso_full="$base$redhat_sso"
    CURL -b "$COOKIES" -c "$COOKIES" -L "$redhat_sso_full"
    curl_expect_200
}

# Step 2
# Display the token
function display_token() {
    base="$1"
    action=$(curl_output | html_read_attr 'action' 'form')
    code=$(curl_output | html_read_attr 'value' 'form input[name~="code"]')
    csrf=$(curl_output | html_read_attr 'value' 'form input[name~="csrf"]')
    display_token_url="$base$action"
    CURL -XPOST \
        -H "content-type: application/x-www-form-urlencoded" \
        -d "code=$code&csrf=$csrf" \
        -b "$COOKIES" -c "$COOKIES" \
        -L "$display_token_url"
    curl_expect_200
}

# Step 3
# Get the auth token
function extract_cluster_token() {
    curl_output | html_read_text 'code'
}

function cluster_token() {
    oauth_endpoint="$1"
    cluster_token_request "$oauth_endpoint"
    display_token "$oauth_endpoint"
    extract_cluster_token
}

cluster_token "$@"
