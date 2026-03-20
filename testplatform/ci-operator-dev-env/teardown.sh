
#!/bin/bash

base=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

b01 --as system:admin delete -f "${base}/debug-pod/ci-operator-debug-pod.yaml"
b01 --as system:admin delete -f "${base}/debug-pod/configmap-config.yaml"
b01 --as system:admin delete -f "${base}/ci-operator/client-proxy-configmap.yaml"
b01 --as system:admin delete -Rf "${base}/boskos"
b01 --as system:admin delete -f "${base}/ci-operator/configresolver.yaml"

