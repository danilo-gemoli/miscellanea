# gcloud commands

## Set Credentials and Project
```sh
export GOOGLE_APPLICATION_CREDENTIALS=gce.json
gcloud config set project $(jq -r .project_id gce.json)

# Check the project
gcloud config get-value project
```

## Quotas
```sh
# Describe quotas per region
gcloud compute regions describe us-central1 --format="json"

# Describe a single quota
gcloud beta quotas info describe T2A-CPUS-per-project-zone --service=compute.googleapis.com --project=openshift-gce-devel-ci-2

# Quotas across regions and zones
gcloud beta quotas info list --service=compute.googleapis.com --project=openshift-gce-devel-ci-2 --format=json \
  | jq '.[]|select(.quotaId=="T2A-CPUS-per-project-zone" or .quotaId=="T2A-CPUS-per-project-region")
        |{quotaId: .quotaId, limit: (.dimensionsInfos[].details.value)}'
{
  "quotaId": "T2A-CPUS-per-project-region",
  "limit": "500"
}
{
  "quotaId": "T2A-CPUS-per-project-zone",
  "limit": "-1"
}

```

## Machines
```sh
# Check whether t2a-standard-4 is available in a zone
gcloud compute machine-types describe t2a-standard-4 --zone=us-central1-a

# Zones that support t2a-standard-4
gcloud compute machine-types list --filter="name=t2a-standard-4 AND zone ~ us-central1" --format="value(zone)"
us-central1-a
us-central1-b
us-central1-f

# Hardware needed by t2a-standard-4
gcloud compute machine-types describe t2a-standard-4 --zone=us-central1-a
```

## Logs
```sh
gcloud logging read 'protoPayload.status.message=~"quota|capacity|unavailable|ZONE_RESOURCE_POOL_EXHAUSTED"
    AND protoPayload.authenticationInfo.principalEmail=~"ci-op-2m7xl4n3"
    AND resource.labels.zone="us-central1-a"
    AND timestamp>="2026-04-16T00:00:00Z"
    AND timestamp<"2026-04-17T00:00:00Z"' \
  --format=json --limit=1000
```
