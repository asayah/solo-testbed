#!/bin/bash

CONTEXT=$1

### check to make sure that arguments were set before taking off
if [[ ${CONTEXT} == "" ]]
then
  echo "Proper usage is ./install-script.sh <context>"
  echo "example:"
  echo "./install-argocd.sh mgmt"
  echo "would install argocd on the mgmt context"
  exit 1
else
  echo "Beginning install on context ${CONTEXT}...."
fi

# use context
kubectl config use-context ${CONTEXT}

# download istio 1.10.2
#export ISTIO_VERSION=1.10.2
#curl -L https://istio.io/downloadIstio | sh -

# deploy istio-operator argo application
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/istio/istio-operator.yaml

### check istio-operator deployment status
./scripts/wait-for-rollout.sh deployment istio-operator istio-operator 10

# deploy istio argo application
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/istio/workshop/cluster1.yaml

### check istio deployment status
./scripts/wait-for-rollout.sh deployment istio-ingressgateway istio-system 10

### deploy bookinfo app
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/frontend/bookinfo-v1-mesh.yaml

### check bookinfo-v1 deployment status
./scripts/wait-for-rollout.sh deployment productpage-v1 bookinfo-v1 10

# get istio URL
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
