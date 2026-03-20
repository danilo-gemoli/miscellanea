#!/bin/bash

base=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# b01 --as system:admin apply -f "${base}/ci-operator/client-proxy-configmap.yaml"
# b01 --as system:admin apply -Rf "${base}/boskos"
# b01 --as system:admin apply -f "${base}/ci-operator/configresolver.yaml"

yq -i ".users[0].user.tokenFile = \"$HOME/.kube/testplatform/build01-token\"" "${base}/build01-kubeconfig.yaml"
KUBECONFIG="${base}/build01-kubeconfig.yaml" ${base}/ci-operator-env-setup.sh
# b01 --as system:admin apply -f "${base}/debug-pod/configmap-config.yaml"

