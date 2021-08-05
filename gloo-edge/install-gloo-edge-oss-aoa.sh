#!/bin/bash

CONTEXT=$1

### check to make sure that arguments were set before taking off
if [[ ${CONTEXT} == "" ]]
then
  echo "Missing arguments. Proper usage is ./install-script.sh <context>"
  echo "example:"
  echo "./install-gloo-edge-aoa.sh cluster1"
  echo "would install open source gloo edge on cluster1"
  exit 1
else
  echo "Beginning install on context ${CONTEXT}...."
fi

# use context
kubectl config use-context ${CONTEXT}

# deploy gloo-edge app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/oss/edge/meta/meta-gloo-edge.yaml

### check gloo-edge deployment status
../tools/wait-for-rollout.sh deployment gateway gloo-system 10

# deploy frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/oss/frontend/meta/meta-frontend-apps.yaml

# deploy virtualservices app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/oss/virtualservice/meta/meta-virtualservices.yaml