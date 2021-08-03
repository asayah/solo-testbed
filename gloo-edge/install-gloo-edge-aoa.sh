#!/bin/bash

CONTEXT=$1
GLOO_FED=$2

### check to make sure that arguments were set before taking off
if [[ ${CONTEXT} == "" ]]
then
  echo "Missing arguments. Proper usage is ./install-script.sh <context>"
  echo "example:"
  echo "./install-argocd.sh mgmt"
  echo "would install argocd on the mgmt context"
  exit 1
else
  echo "Beginning install on context ${CONTEXT}...."
fi

# use context
kubectl config use-context ${CONTEXT}

# deploy gloo-edge app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/edge/meta/meta-gloo-edge.yaml

### check gloo-edge deployment status
../tools/wait-for-rollout.sh deployment gateway gloo-system 10

# deploy frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/frontend/meta/meta-frontend-apps.yaml

# deploy virtualservices app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/virtualservice/meta/meta-virtualservices.yaml

if [[ $GLOO_FED == "yes" ]]
  then 
  # deploy gloo-fed-ee
  kubectl --context ${CONTEXT} create -f gloo-fed-ee-helm.yaml
  # wait for gloo-fed-ee to deploy
  ../tools/wait-for-rollout.sh deployment gloo-fed gloo-system 10
  # register cluster
  echo "registering cluster with command: glooctl cluster register --cluster-name ${CONTEXT} --remote-context ${CONTEXT} --remote-namespace gloo-system "
  glooctl cluster register --cluster-name ${CONTEXT} --remote-context ${CONTEXT} --remote-namespace gloo-system
  # echo complete
  echo gloo-fed-ee installation complete
fi