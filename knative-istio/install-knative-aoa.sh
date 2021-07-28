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
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/knative-istio/operator/meta/meta-operator-app.yaml

# wait for important operators
### check istio-operator deployment status
../tools/wait-for-rollout.sh deployment istio-operator istio-operator 10

# Install platform app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/knative-istio/platform/meta/meta-platform-app.yaml

### check istio deployment status
../tools/wait-for-rollout.sh deployment istio-ingressgateway istio-system 10

### check knative-serving deployment status
../tools/wait-for-rollout.sh deployment controller knative-serving 10

### label default namespace with istio-injected=enabled
kubectl label namespace default istio-injection=enabled

# Install frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/knative-istio/frontend/meta/meta-frontend-app.yaml

### check hello-world kn deployment status
../tools/wait-for-rollout.sh deployment hello-world-deployment default 5

### get istio-ingressgateway IP
GATEWAY_IP=$(kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{ print $4 }')
echo your istio gateway IP is ${GATEWAY_IP}

### trigger the hello-world kn service
curl -v ${GATEWAY_IP} -H "Host: hello.default.example.com"

### watch scaledown to zero
kubectl get pod -l serving.knative.dev/service=hello -w