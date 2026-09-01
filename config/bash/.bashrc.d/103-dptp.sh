if [ -z $BASH_INIT_DPTP ]; then
    export BUILD_FARM="$(yq '.contexts[].name' $HOME/.kube/testplatform/testplatform-kubeconfig.yaml)"
    export BUILD_CLUSTERS="$(yq '.contexts[].name' $HOME/.kube/testplatform/testplatform-kubeconfig.yaml | grep build)"
    function appci() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="app.ci" $@; }
    function coreci() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="core-ci" $@; }
    function b01() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build01" $@; }
    function b02() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build02" $@; }
    function b03() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build03" $@; }
    function b04() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build04" $@; }
    function b05() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build05" $@; }
    function b06() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build06" $@; }
    function b07() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build07" $@; }
    function b08() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build08" $@; }
    function b09() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build09" $@; }
    function b10() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build10" $@; }
    function b11() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build11" $@; }
    function b12() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build12" $@; }
    function b13() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="build13" $@; }
    function vs02() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="vsphere02" $@; }
    function hostmgmt() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="hosted-mgmt" $@; }
    function hive() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="hive" $@; }
    function arm01() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="arm01" $@; }
    function mul01() { oc --kubeconfig="$HOME/.kube/testplatform/testplatform-kubeconfig.yaml" --context="multi01" $@; }
    export -f appci
    export -f coreci
    export -f b01
    export -f b02
    export -f b03
    export -f b04
    export -f b05
    export -f b06
    export -f b07
    export -f b08
    export -f b09
    export -f b10
    export -f b11
    export -f b12
    export -f b13
    export -f vs02
    export -f hostmgmt
    export -f hive
    export -f arm01
    export -f mul01
    export BASH_INIT_DPTP=1
fi
