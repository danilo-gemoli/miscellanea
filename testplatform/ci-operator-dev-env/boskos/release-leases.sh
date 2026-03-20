#!/bin/bash

ns='dgemoli-ci-operator-debug'
leased=$(b01 -n $ns get resource -ojson \
  | jq -r '.items[]|select(.status.state=="leased")|.metadata.name + "_" + .status.owner')

pf_pid=-1
if ! $(netstat -ntpl 2>&1 | grep -qF '127.0.0.1:8080'); then
    echo 'Opening a tunnel to boskos service'
    b01 --as system:admin -n $ns port-forward service/boskos 8080:80 &
    pf_pid=$!
    
    # Wait some time to establish the tunnel
    sleep 5s
fi

for l in $leased; do
    lease=$(cut -d'_' -f1 <<<"$l")
    owner=$(cut -d'_' -f2 <<<"$l")
    echo "Releasing lease: $lease - owner: $owner"
    boskosctl release \
      --name="$lease" \
      --owner-name="$owner" \
      --server-url='http://localhost:8080' \
      --target-state=free
done

if [ $pf_pid -ne -1 ]; then
    echo "killing $pf_pid"
    kill $pf_pid
fi

