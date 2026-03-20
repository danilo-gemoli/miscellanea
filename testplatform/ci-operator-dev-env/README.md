dlv exec /usr/bin/ci-operator 

** dlv

Breakpoints
```
b github.com/openshift/ci-tools/pkg/steps/multi_stage.(*multiStageTestStep).run
b /home/dgemoli/dev/src/github.com/danilo-gemoli/ci-tools/pkg/steps/multi_stage/multi_stage.go:263
```

** ci-operator

Upload the `ci-operator` binary on the debug pod:
```sh
go install ./cmd/ci-operator/...
b01 --as system:admin -n ci cp --retries=3 -c test $(which ci-operator) dgemoli-ci-operator-debug:/tmp/ci-operator
```

`ci-operator` run:
```sh
/tmp/ci-operator \
--namespace=dgemoli-ci-operator-debug \
--delete-when-idle=0 \
--delete-after=0 \
--gcs-upload-secret=/secrets/gcs/service-account.json \
--image-import-pull-secret=/etc/pull-secret/.dockerconfigjson \
--lease-server-credentials-file=/etc/boskos/credentials \
--report-credentials-file=/etc/report/credentials \
--secret-dir=/secrets/ci-pull-credentials \
--lease-server=http://boskos.dgemoli-ci-operator-debug.svc.cluster.local \
--resolver-address=http://ci-operator-configresolver.dgemoli-ci-operator-debug.svc.cluster.local \
--config=/tmp/ci-operator-config/config.yaml \
--target=fake-e2e

# Without a custom configresolver
/tmp/ci-operator \
--namespace=dgemoli-ci-operator-debug \
--delete-when-idle=0 \
--delete-after=0 \
--gcs-upload-secret=/secrets/gcs/service-account.json \
--image-import-pull-secret=/etc/pull-secret/.dockerconfigjson \
--lease-server-credentials-file=/etc/boskos/credentials \
--report-credentials-file=/etc/report/credentials \
--secret-dir=/secrets/ci-pull-credentials \
--lease-server=http://boskos.dgemoli-ci-operator-debug.svc.cluster.local \
--config=/tmp/ci-operator-config/config.yaml \
--target=fake-e2e

```

dlv run cmd:
```sh
dlv exec /usr/bin/ci-operator -- \
--namespace=dgemoli-ci-operator-debug \
--delete-when-idle=0 \
--delete-after=0 \
--gcs-upload-secret=/secrets/gcs/service-account.json \
--image-import-pull-secret=/etc/pull-secret/.dockerconfigjson \
--lease-server-credentials-file=/etc/boskos/credentials \
--report-credentials-file=/etc/report/credentials \
--secret-dir=/secrets/ci-pull-credentials \
--lease-server=http://boskos.dgemoli-ci-operator-debug.svc.cluster.local \
--resolver-address=http://ci-operator-configresolver.dgemoli-ci-operator-debug.svc.cluster.local \
--config=/tmp/ci-operator-config/config.yaml \
--target=fake-e2e
```

dlv listen cmd:
```sh
b01 --as system:admin -n ci port-forward dgemoli-ci-operator-debug 5555

dlv exec /tmp/ci-operator --headless --accept-multiclient -l 127.0.0.1:5555 -- \
--namespace=dgemoli-ci-operator-debug \
--delete-when-idle=0 \
--delete-after=0 \
--gcs-upload-secret=/secrets/gcs/service-account.json \
--image-import-pull-secret=/etc/pull-secret/.dockerconfigjson \
--lease-server-credentials-file=/etc/boskos/credentials \
--report-credentials-file=/etc/report/credentials \
--secret-dir=/secrets/ci-pull-credentials \
--lease-server=http://boskos.dgemoli-ci-operator-debug.svc.cluster.local \
--resolver-address=http://ci-operator-configresolver.dgemoli-ci-operator-debug.svc.cluster.local \
--config=/tmp/ci-operator-config/config.yaml \
--target=fake-e2e
```

** boskos
Monitor resources:
```sh
watch -n 3 -- b01 -n dgemoli-ci-operator-debug get resources
```
