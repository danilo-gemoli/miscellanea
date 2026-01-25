package main

import (
	"fmt"
	"os"

	jsonpatch "gopkg.in/evanphx/json-patch.v4"
	"sigs.k8s.io/yaml"
)

var yamlObj = `
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  name: build11-vxs6g-ci-prowjobs-worker-amd64-us-east-2a
  namespace: openshift-machine-api
  labels:
    machine.openshift.io/cluster-api-cluster: build11-vxs6g
spec:
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: build11-vxs6g
      machine.openshift.io/cluster-api-machineset: build11-vxs6g-ci-prowjobs-worker-amd64-us-east-2a
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: build11-vxs6g
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: build11-vxs6g-ci-prowjobs-worker-amd64-us-east-2a
    spec:
      metadata:
        labels:
          ci-workload: prowjobs
      taints:
      - effect: NoSchedule
        key: node-role.kubernetes.io/ci-prowjobs-worker
        value: ci-prowjobs-worker
      providerSpec:
        value:
          userDataSecret:
            name: worker-user-data
          placement:
            availabilityZone: us-east-2a
            region: us-east-2
          credentialsSecret:
            name: aws-cloud-credentials
          instanceType: m6a.4xlarge
          metadata:
            creationTimestamp: null
          publicIp: true
          blockDevices:
            - ebs:
                encrypted: true
                iops: 0
                kmsKey:
                  arn: ''
                volumeSize: 800
                volumeType: gp3
`

// yaml mixed with json
var patch = `spec: {"template":{"spec":{"providerSpec":{"value":{"blockDevices":[{"ebs":{"iops":5000}}]}}}}}`

type Patch struct {
	labels []string `json:"matchLabels,omitempty"`
	p      string   `json:"patch,omitemtpy"`
}

func main() {
	jsonPatch, err := yaml.YAMLToJSON([]byte(patch))
	if err != nil {
		fmt.Printf("patch yaml to json: %s", err)
		os.Exit(1)
	}

	jsonObj, err := yaml.YAMLToJSON([]byte(yamlObj))
	if err != nil {
		fmt.Printf("obj yaml to json: %s", err)
		os.Exit(1)
	}

	jsonObjPatched, err := jsonpatch.MergePatch(jsonObj, jsonPatch)
	if err != nil {
		fmt.Printf("patch: %s", err)
		os.Exit(1)
	}

	yamlObjPatched, err := yaml.JSONToYAML(jsonObjPatched)
	if err != nil {
		fmt.Printf("json to yaml: %s", err)
		os.Exit(1)
	}

	fmt.Printf("%s", yamlObjPatched)
}
