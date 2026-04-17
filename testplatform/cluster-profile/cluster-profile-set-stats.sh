#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
leases="$(appci -n ci get resources)"

for cluster_profile in openshift-org-aws openshift-org-azure; do
    printf 'Set %s\n' "$cluster_profile"
    appci -n ci get resources | awk -v clusterprofile="$cluster_profile" -f "${SCRIPT_DIR}/cluster-profile-set-stats.awk"
    echo
done

echo 'Legacy AWS Profiles:'
awk '{ if ($2 ~ /^aws(-[2-5])?-quota-slice/) print $2 " " $3 }' <<<$leases | sort | uniq -c | sort -rk2

echo

echo 'Legacy Azure Profiles:'
awk '{ if ($2 ~ /^azure(-2|4)-quota-slice/) print $2 " " $3 }' <<<$leases | sort | uniq -c | sort -rk2

