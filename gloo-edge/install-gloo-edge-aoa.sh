#!/bin/bash

CONTEXT=$1
FEATURES=$2

### check to make sure that arguments were set before taking off
if [[ ${CONTEXT} == "" ]] || [[ ${FEATURES} == "" ]]
then
  echo "Missing arguments. Proper usage is ./install-script.sh <context> <oss/ee>"
  echo "example:"
  echo "./install-gloo-edge-aoa.sh cluster1 oss"
  echo "would install open source gloo edge on cluster1"
  exit 1
else
  echo "Beginning install on context ${CONTEXT}...."
fi

# use context
kubectl config use-context ${CONTEXT}

if [[ ${FEATURES} == "ee" ]]
  then 
  # deploy gloo-edge-ee argo-app (has license key in manifest so is sensitive)
  kubectl --context ${CONTEXT} create -f non-aoa/gloo-edge-ee-helm.yaml
fi

# deploy gloo-edge app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge-${FEATURES}/edge/meta/meta-gloo-edge.yaml

### check gloo-edge deployment status
../tools/wait-for-rollout.sh deployment gateway gloo-system 10

# deploy frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge-${FEATURES}/frontend/meta/meta-frontend-apps.yaml

# deploy virtualservices app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge-${FEATURES}/virtualservice/meta/meta-virtualservices.yaml

if [[ ${FEATURES} == "ee" ]]
  then 
  # wait for gloo-fed-ee to deploy
  ../tools/wait-for-rollout.sh deployment gloo-fed gloo-system 10
  # register cluster
  echo "registering cluster with command: glooctl cluster register --cluster-name ${CONTEXT} --remote-context ${CONTEXT} --remote-namespace gloo-system "
  glooctl cluster register --cluster-name ${CONTEXT} --remote-context ${CONTEXT} --remote-namespace gloo-system
  # echo complete
  echo gloo-fed-ee installation complete
  # wait for keycloak to deploy
  ../tools/wait-for-rollout.sh deployment keycloak default 10
  # set up keycloak
  ./keycloak-setup.sh
fi