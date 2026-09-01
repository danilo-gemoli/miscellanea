#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/common.sh"

function do_auth_redhat_authenticate() {
    action=$(curl_output | html_read_attr 'action' 'form[id~="login-form"]')
    content_type=$(curl_output | html_read_attr 'enctype' 'form[id~="login-form"]')
    submit=$(curl_output | html_read_attr 'value' 'input[id~="submit"]')
    read -p 'Kerberos ID: ' username
    read -sp 'PIN + TOKEN: ' password
    CURL -XPOST -L \
        -b "$COOKIES" -c "$COOKIES" \
        -H "content-type: $content_type" \
        -d "username=$username&password=$password&submit=$submit" \
        "$action"
}

function is_auth_redhat_authenticate() {
    title=$(curl_output | html_read_text 'title')
    [[ "$title" =~ "Red Hat Internal SSO" ]]
}


function touch_cookies() {
    printf "" >"$COOKIES"
}

# Step 1
# GET https://auth.redhat.com
# click on 'CONTINUE' button (that's due to not having any JS capabilites)
function auth_redhat() {
    CURL -L -c "$COOKIES" "$url_auth_redhat_com"
    curl_expect_401
    action=$(curl_output | html_read_attr 'action' 'form')
    continue_value=$(curl_output | html_read_attr 'value' 'input')
    CURL -XPOST -L \
        -b "$COOKIES" -c "$COOKIES" \
        -H "content-type: application/x-www-form-urlencoded" \
        -d "continue=$continue_value" \
        "$action"
    curl_expect_200
}

# Step 2
# Submit the Kerberos ID and PIN + token
function auth_redhat_authenticate() {
    do_auth_redhat_authenticate
    curl_expect_200

    while is_auth_redhat_authenticate; do
        do_auth_redhat_authenticate
        curl_expect_200
    done
}

# Step 3
# Complete the login phase
function auth_redhat_finish_login() {
    href=$(curl_output | html_read_attr 'href' 'a[id~="finishLoginLink"]')
    CURL -b "$COOKIES" -c "$COOKIES" -L "$href"
    curl_expect_200
}

function sso_auth() {
    # It should make sense to start with a fresh session when we want to perform a login from scratch.
    # sso_auth script is intended to be used together with sso_is_auth in the following way:
    # 
    #   COOKIES="/tmp/cookies.txt" sso_is_auth.sh || sso_auth.sh
    touch_cookies

    auth_redhat
    auth_redhat_authenticate
    auth_redhat_finish_login
}

sso_auth
