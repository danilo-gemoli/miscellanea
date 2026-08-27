## Assign a role to a SA
```sh
#!/bin/bash

for profile_dir in gcp gcp-openshift-gce-devel-ci-2 gcp-3; do
    echo "profile $profile_dir"
    
    project_id=$(jq -r .project_id $profile_dir/gce.json)
    sa_email=$(jq -r .client_email $profile_dir/gce.json)
    gcloud config set account $sa_email &>/dev/null
    gcloud config set project $project_id &>/dev/null

    principal=$(printf "serviceAccount:$sa_email")
    gcloud projects add-iam-policy-binding "$project_id" \
      --member="$principal" \
      --role=roles/servicedirectory.editor

    echo "Role roles/servicedirectory.editor assigned to $principal in $project_id"
done
```