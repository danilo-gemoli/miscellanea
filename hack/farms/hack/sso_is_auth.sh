#!/bin/bash

###################
### Description ###
###################
# This script checks if a user is logged into the RH SSO
#################
### Arguments ###
#################
# - 
#####################
### Env Variables ###
#####################
# COOKIES: cookies file curl will read from and write into

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/common.sh"

# Check whether the cookies hold a valid login instance
function sso_is_auth() {
    CURL -I -b "$COOKIES" -L "$url_auth_redhat_com"
    curl_assert_success
    test "$(curl_http_code)" == "200"
}

sso_is_auth
