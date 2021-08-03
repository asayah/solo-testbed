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

# Install operator app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-mesh-istio/operator/meta/meta-operator-app.yaml

# wait for important operators
### check istio-operator deployment status
../tools/wait-for-rollout.sh deployment istio-operator istio-operator 10

# Install platform app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-mesh-istio/platform/meta/meta-platform-app.yaml

### check istio deployment status
../tools/wait-for-rollout.sh deployment istio-ingressgateway istio-system 10

# Install frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-mesh-istio/frontend/meta/meta-frontend-app.yaml

# check sleep deployment status 
../tools/wait-for-rollout.sh deployment sleep default 5

echo done