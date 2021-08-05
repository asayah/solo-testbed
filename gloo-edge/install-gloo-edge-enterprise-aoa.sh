#!/bin/bash

CONTEXT=$1
FED=$2

### check to make sure that arguments were set before taking off
if [[ ${CONTEXT} == "" ]] || [[ ${FED} == "" ]]
then
  echo "Missing arguments. Proper usage is ./install-script.sh <context> <fed/nofed>"
  echo "example:"
  echo "./install-gloo-edge-aoa.sh cluster1 fed"
  echo "would install enterprise gloo edge on cluster1 with gloo-fed enabled"
  exit 1
else
  echo "Beginning install on context ${CONTEXT}...."
fi

# use context
kubectl config use-context ${CONTEXT}

# check to see if license key has been provided
LICENSE=$(cat gloo-edge-ee-license.yaml | grep license-key: | awk '{ print $2 }')
  if [[ ${LICENSE} == "<INSERT_BASE_64_ENCODED_LICENSE_HERE>" ]]
    then
    echo "no license key provided, please replace <INSERT_BASE_64_ENCODED_LICENSE_HERE> value in the gloo-edge-ee-license.yaml to continue"
    exit 1
  fi

# create gloo-system namespace
kubectl --context ${CONTEXT} create ns gloo-system

# deploy gloo-edge-ee argo-app (has license key in manifest so is sensitive)
kubectl --context ${CONTEXT} create -f gloo-edge-ee-license.yaml

# deploy gloo-edge app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/ee/${FED}/edge/meta/meta-gloo-edge.yaml

### check gloo-edge deployment status
../tools/wait-for-rollout.sh deployment gateway gloo-system 10

# deploy frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/ee/${FED}/frontend/meta/meta-frontend-apps.yaml

# deploy virtualservices app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/ee/${FED}/virtualservice/meta/meta-virtualservices.yaml

if [[ ${FED} == "fed" ]]
  then 
  # wait for gloo-fed-ee to deploy
  ../tools/wait-for-rollout.sh deployment gloo-fed gloo-system 10
  # register cluster
  echo "registering cluster with command: glooctl cluster register --cluster-name ${CONTEXT} --remote-context ${CONTEXT} --remote-namespace gloo-system "
  glooctl cluster register --cluster-name ${CONTEXT} --remote-context ${CONTEXT} --remote-namespace gloo-system
  # echo complete
  echo gloo-fed-ee installation complete
fi

# wait for keycloak to deploy
../tools/wait-for-rollout.sh deployment keycloak default 10
# set up keycloak
./keycloak-setup.sh