#!/bin/bash

CONTEXT=$1

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

# install meshctl CLI
#export GLOO_MESH_VERSION=v1.0.9
#curl -sL https://run.solo.io/meshctl/install | sh -
#export PATH=$HOME/.gloo-mesh/bin:$PATH

# deploy gloo-mesh-oss-helm argo application
# creating from YAML because of sensitive values (license key)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/gloo-mesh/gloo-mesh-oss-helm.yaml

### check gloo-edge deployment status
../tools/wait-for-rollout.sh deployment networking gloo-mesh 10

### check to see if components are deployed
kubectl --context ${CONTEXT} get pods -n gloo-mesh