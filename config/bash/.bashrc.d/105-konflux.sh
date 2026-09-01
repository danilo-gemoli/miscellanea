if [ -z $BASH_INIT_KONFLUX ]; then
    function rh01() { oc --kubeconfig="$HOME/.kube/konflux/prd-rh01-kubeconfig.yaml" --context="rh01" $@; }
    function rh01login() { 
        kubeconfig="$HOME/.kube/konflux/prd-rh01-kubeconfig.yaml"
        [ -f "$kubeconfig" ] && rm "$kubeconfig"
        oc --kubeconfig="$HOME/.kube/konflux/prd-rh01-kubeconfig.yaml" --context="rh01" login -w 'https://api.stone-prd-rh01.pg1f.p1.openshiftapps.com:6443';
        yq -i '.contexts[0].name="rh01"|.contexts[0].context.namespace="rh-ee-dgemoli-tenant"|.current-context="rh01"' ~/.kube/konflux/prd-rh01-kubeconfig.yaml
    }

    function srh01() { oc --kubeconfig="$HOME/.kube/konflux/stg-rh01-kubeconfig.yaml" --context="stg-rh01" $@; }
    function srh01login() { 
        kubeconfig="$HOME/.kube/konflux/stg-rh01-kubeconfig.yaml"
        [ -f "$kubeconfig" ] && rm "$kubeconfig"
        oc --kubeconfig="$HOME/.kube/konflux/stg-rh01-kubeconfig.yaml" --context="stg-rh01" login -w 'https://api.stone-stg-rh01.l2vh.p1.openshiftapps.com:6443';
        yq -i '.contexts[0].name="stg-rh01"|.contexts[0].context.namespace="testplatform-ci-tenant"|.current-context="stg-rh01"' ~/.kube/konflux/stg-rh01-kubeconfig.yaml
    }
    
    export -f rh01
    export -f rh01login
    export -f srh01
    export -f srh01login
    export BASH_INIT_KONFLUX=1
fi

