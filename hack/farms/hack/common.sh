###################
### Description ###
###################
# Some utilities
#####################
### Env Variables ###
#####################
# XCURL_DEBUG: dump debugging information of curl

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
url_auth_redhat_com='https://auth.redhat.com'

function html_read_attr() {
    attr="$1"
    selector="$2"
    "$script_dir/hq.py" -a "$attr" "$selector"
}

function html_read_text() {
    selector="$1"
    "$script_dir/hq.py" "$selector"
}

_curl_output=""
_curl_raw_output=""
_curl_http_code=""
_curl_args=""
_curl_exit_code=0
function CURL() {
    _curl_args="$@"
    _curl_raw_output=$(curl -s -w '\n>>>%{json}\n' "$@")
    _curl_exit_code=$?
    _curl_output=$(printf "%s" "$_curl_raw_output" | grep -vE '^>>>')
    j=$(printf "%s" "$_curl_raw_output" | grep -E '^>>>' | tail -n1 | sed 's/>>>//g')
    _curl_http_code=$(jq '.http_code' <<<$j)
    if [ ! -z "$XCURL_DEBUG" ]; then
        printf "***\nargs: %s\noutput:\n%s\n***\n" "$_curl_args" "$_curl_raw_output"
    fi
}

function curl_exit_code() {
    return $_curl_exit_code
}

function curl_output() {
    printf "%s" "$_curl_output"
}

function curl_http_code() {
    printf "%s" "$_curl_http_code"
}

function curl_assert_http_code() {
    expected="$1"
    if [ "$_curl_http_code" != "$expected" ]; then
        printf "\nexpected: %s\nhttp_code: %s\nargs: %s\noutput:\n%s\n" "$expected" \
            "$_curl_http_code" "$_curl_args" "$_curl_raw_output"
        exit 1
    fi
}

function curl_assert_success() {
    c=$(curl_exit_code)
    if [ ! "$c" != "0" ]; then
        printf "\ncurl unexpected exit code: %d\n" $c
        printf "http_code: %s\nargs: %s\noutput:\n%s\n" "$_curl_http_code" "$_curl_args" "$_curl_raw_output"
        exit $c
    fi
}

function curl_expect_200() {
    curl_assert_success
    curl_assert_http_code "200"
}

function curl_expect_401() {
    curl_assert_success
    curl_assert_http_code "401"
}
