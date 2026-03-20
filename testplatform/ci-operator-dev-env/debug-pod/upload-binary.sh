#!/bin/bash

base=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd $repo_danilogemoli_citools &>/dev/null
echo 'installing ci-operator'
go install ./cmd/ci-operator/...
podp &>/dev/null

ci_operator_path="$(which ci-operator)"
echo 'uploading ci-operator'
b01 --as system:admin cp -c test --retries=3 "$ci_operator_path" ci/dgemoli-ci-operator-debug:/tmp/ci-operator

