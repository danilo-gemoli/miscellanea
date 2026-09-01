# Farmslogin
`farmslogin` is a small utility that logs the user into a list of predefined cluster.
The tool checks whether the user is logged into the RedHat SSO already and, if he isn't,
it attemps to perform a new login.  

---

### Examples
Regular login:
```sh
COOKIES="$HOME/.kube/cookies.txt" hack/login.sh -k "$HOME/.kube/configs"
```

Get a token for a cluster:
```sh
COOKIES="$HOME/.kube/cookies.txt" hack/cluster_token.sh \
  'https://oauth-openshift.apps.build01.ci.devcluster.openshift.com'
```

Check if the user is logged in already:
```sh
COOKIES="$HOME/.kube/cookies.txt" hack/sso_is_auth.sh
```

### Requirements
- bash
- python3
  - BeautifulSoup library
- curl
- yq
- jq
- oc
