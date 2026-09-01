#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function cluster_token() {
    "$script_dir/cluster_token.sh" "$@"
}

function cluster_login() {
    oauth_endpoint="$1"
    token_file="$2"
    cluster_token "$oauth_endpoint" >"$token_file"
    if [ $? -ne 0 ]; then
        printf "Login to %s FAILED!\n" "$oauth_endpoint"
    fi
}

cluster_login "$@"
