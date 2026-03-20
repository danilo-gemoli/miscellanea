function kubeconfig {
   token=$(oc --as system:admin -n ci create token --duration=8h ci-operator)   cluster_api="${CLUSTER_API:-https://api.build01.ci.devcluster.openshift.com:6443}"
   cat >kubeconfig.yaml <<EOF
apiVersion: v1
clusters:
- cluster:
    server: $cluster_api
  name: build-cluster
contexts:
- context:
    cluster: build-cluster
    namespace: ci
    user: ci-operator
  name: build-cluster
kind: Config
current-context: build-cluster
preferences: {}
users:
- name: ci-operator
  user:
    token: $token
EOF
}

function secrets {
   oc --as system:admin -n ci extract secret/gce-sa-credentials-gcs-publisher --to="$PWD/secrets/gcs" --confirm
   oc --as system:admin -n ci extract secret/manifest-tool-local-pusher --to="$PWD/secrets/manifest-tool-local-pusher" --confirm
   oc --as system:admin -n ci extract secret/registry-pull-credentials --to="$PWD/secrets/pull-secret" --confirm
   oc --as system:admin -n ci extract secret/boskos-credentials --to="$PWD/secrets/boskos" --confirm
   oc --as system:admin -n ci extract secret/ci-pull-credentials --to="$PWD/secrets/ci-pull-credentials" --confirm
}

function build_id {
   for i in {1..20}; do
       x=$(od -N1 -t u /dev/random | head -1 | awk '{print $2}')
       printf "$((($x % 9)+1))";
   done | tr -d '\n'
}

function jobspec {
   job_name="$1"
   pj_id=$(uuidgen)
   build_id=$(build_id)
   cat <<EOF | jq -c >jobspec.json
{
 "type": "postsubmit",
 "job": "$job_name",
 "buildid": "$build_id",
 "prowjobid": "$pj_id",
 "refs": {
   "org": "openshift",
   "repo": "ci-tools",
   "repo_link": "https://github.com/openshift/ci-tools",
   "base_ref": "master",
   "base_sha": "fbbc82d4328b3b759037ce8e31ad092084b8e585",
   "base_link": "https://github.com/openshift/ci-tools/commit/fbbc82d4328b3b759037ce8e31ad092084b8e585",
   "pulls": [
     {
       "number": 1,
       "author": "fake",
       "sha": "fbbc82d4328b3b759037ce8e31ad092084b8e585"
     }
   ]
 },
 "decoration_config": {
   "timeout": "4h0m0s",
   "grace_period": "1h0m0s",
   "utility_images": {
     "clonerefs": "us-docker.pkg.dev/k8s-infra-prow/images/clonerefs:v20241224-8e8a5cfe7",
     "initupload": "us-docker.pkg.dev/k8s-infra-prow/images/initupload:v20241224-8e8a5cfe7",
     "entrypoint": "us-docker.pkg.dev/k8s-infra-prow/images/entrypoint:v20241224-8e8a5cfe7",
     "sidecar": "us-docker.pkg.dev/k8s-infra-prow/images/sidecar:v20241224-8e8a5cfe7"
   },
   "resources": {
     "clonerefs": {
       "limits": {
         "memory": "3Gi"
       },
       "requests": {
         "cpu": "100m",
         "memory": "500Mi"
       }
     },
     "initupload": {
       "limits": {
         "memory": "200Mi"
       },
       "requests": {
         "cpu": "100m",
         "memory": "50Mi"
       }
     },
     "place_entrypoint": {
       "limits": {
         "memory": "100Mi"
       },
       "requests": {
         "cpu": "100m",
         "memory": "25Mi"
       }
     },
     "sidecar": {
       "limits": {
         "memory": "2Gi"
       },
       "requests": {
         "cpu": "100m",
         "memory": "250Mi"
       }
     }
   },
   "gcs_configuration": {
     "bucket": "origin-ci-test",
     "path_strategy": "single",
     "default_org": "openshift",
     "default_repo": "origin",
     "mediaTypes": {
       "log": "text/plain"
     }
   },
   "gcs_credentials_secret": "gce-sa-credentials-gcs-publisher",
   "censor_secrets": true
 }
}
EOF
}

base=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [ -z "$KUBECONFIG" ]; then
    export KUBECONFIG="${base}/build01-kubeconfig.yaml"
fi

workbench='/tmp/ci-operator'
[ ! -d "$workbench" ] && mkdir -p "$workbench"
[ ! -d "$workbench/artifacts" ] && mkdir -p "$workbench/artifacts"

pushd "$workbench" &>/dev/null
   kubeconfig
   secrets
   jobspec "ci-op-degemoli-test"
popd &>/dev/null

