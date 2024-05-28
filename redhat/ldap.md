## LDAP
VPN connection is required!
Corporate server addr: `ldap://ldap.corp.redhat.com`

### Get a user
ldapsearch -LLL -x -H 'ldap://ldap.corp.redhat.com' -b ou=users,dc=redhat,dc=com '(uid=dgemoli)' '*'

### Get all groups
ldapsearch -LLL -x -H 'ldap://ldap.corp.redhat.com' -b ou=Groups,dc=redhat,dc=com '*' 

