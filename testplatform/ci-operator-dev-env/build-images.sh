#!/bin/bash

base=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

images="${1:-all}"
if [ "$images" == "all" ]; then
    images=$(ls "${base}/images/*.Containerfile" | cut -d'.' -f1)
fi

# Build and push an image that holds the tool passed as an argument.
function build_and_push() {
    tool="$1"
    pushd "${HOME}/dev/src/github.com/danilo-gemoli/ci-tools/" &>/dev/null
    go install ./cmd/${tool}/...
    popd &>/dev/null

    podman build --tag=${tool} -f "${base}/images/${tool}.Containerfile" ${HOME}
    podman push "localhost/${tool}:latest" \
        "registry.build01.ci.openshift.org/dgemoli-ci-operator-debug/${tool}:latest"
}

images_rbac='/home/dgemoli/dev/workbench/image-registry/permissions.yaml'

b01 registry login
b01 --as system:admin apply -f "$images_rbac"

for image in $images; do
    build_and_push $image
done

b01 --as system:admin delete -f "$images_rbac"

