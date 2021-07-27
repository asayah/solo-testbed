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
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istio/operator/meta/meta-operator-app.yaml

# wait for important operators
### check istio-operator deployment status
../tools/wait-for-rollout.sh deployment istio-operator istio-operator 10

# Install platform app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istio/platform/meta/meta-platform-app.yaml

### check istio deployment status
../tools/wait-for-rollout.sh deployment istio-ingressgateway istio-system 10

# Install frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istio/frontend/meta/meta-frontend-app.yaml

### check bookinfo-v1 deployment status
../tools/wait-for-rollout.sh deployment productpage-v1 bookinfo-v1 10

# check sleep deployment status 
../tools/wait-for-rollout.sh deployment sleep default 5

# curl 
for i in {1..10}; do kubectl exec deploy/sleep -n default -- curl http://productpage.bookinfo-v1:9080/productpage; done

for i in {1..10}; do curl http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage; done

# get istio URL
echo for kind deployments:
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
echo for cloud deployments:
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"