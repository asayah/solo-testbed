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

# deploy istio-operator argo application
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/istio-operator-1-9-5.yaml

### check istio-operator deployment status
../scripts/wait-for-rollout.sh deployment istio-operator istio-operator 10

# deploy istio control plane argo application (istioinaction workshop)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/istio-control-plane-1-9-5.yaml

### check istio control plane deployment status
../scripts/wait-for-rollout.sh deployment istiod-1-9-5 istio-system 10

# deploy istio ingress gateway argo application (istioinaction workshop)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/istio-gateway-1-9-5.yaml

### check istio ingress gateway deployment status
../scripts/wait-for-rollout.sh deployment istio-ingressgateway istio-ingress 10

# deploy web-api argo application (istioinaction workshop)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/web-api-istioinaction.yaml

### check web-api deployment status
../scripts/wait-for-rollout.sh deployment web-api web-api 10

# deploy httpbin-injected application (istioinaction workshop)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/injected-httpbin-app.yaml

### check httpbin-injected deployment status
../scripts/wait-for-rollout.sh deployment httpbin httpbin 10