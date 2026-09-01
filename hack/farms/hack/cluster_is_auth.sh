#!/bin/bash

###################
### Description ###
###################
# This script checks if a user is logged into a specific cluster context
#################
### Arguments ###
#################
# --context: the cluster context 
#####################
### Env Variables ###
#####################
# KUBECONFIG: path to a valid kubeconfig

function cluster_is_auth() {
    ctx="$1"
    oc --context="$ctx" whoami 2>&1 | \
        grep -v 'error: You must be logged in to the server (Unauthorized)' | \
        grep -v 'error: read empty token' \
        >/dev/null 2>&1
}

cluster_is_auth "$@"
