## LDAP
VPN connection is required!
Corporate server addr: `ldap://ldap.corp.redhat.com`

### Get user
ldapsearch -LLL -x -H 'ldap://ldap.corp.redhat.com' -b ou=users,dc=redhat,dc=com '(uid=dgemoli)' '*'

### Get user by GitHub id
ldapsearch -LLL -x -H 'ldap://ldap.corp.redhat.com' -b ou=users,dc=redhat,dc=com '(rhatSocialURL=Github->https://github.com/bhargavigudi)' 'cn'

### Get all groups
ldapsearch -LLL -x -H 'ldap://ldap.corp.redhat.com' -b ou=Groups,dc=redhat,dc=com '*' 

