if [ -z $BASH_INIT_REDHAT ]; then
    function rh-by-github-id() {
        ldapsearch -LLL -x -H \
            'ldap://ldap.corp.redhat.com' \
            -b ou=users,dc=redhat,dc=com "(rhatSocialURL=Github->https://github.com/$1)" \
            'cn' \
            | grep --color=never cn \
            | sed -E 's/cn\:\s+//'
    }
    export -f rh-by-github-id
    
    # https://source.redhat.com/departments/strategy_and_operations/it/datacenter_infrastructure/aie/aie_wiki/netbird_overview
    function vpn-connect() {
        netbird up --management-url https://wgvpn.redhat.com:443
        printf 'status: netbird status\ndisconnect: netbird down\n'
    }
    export -f vpn-connect

    export BASH_INIT_REDHAT=1
fi
