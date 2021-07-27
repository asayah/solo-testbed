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

# download istio 1.10.2
#export ISTIO_VERSION=1.10.2
#curl -L https://istio.io/downloadIstio | sh -

# deploy istio-operator argo application
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/istio/operator/istio-operator-1-9-5.yaml

### check istio-operator deployment status
../../tools/wait-for-rollout.sh deployment istio-operator istio-operator 10

# deploy istio argo application (default profile)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/istio/profiles/istio-default.yaml

### check istio deployment status
../../tools/wait-for-rollout.sh deployment istio-ingressgateway istio-system 10

### deploy bookinfo app
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/frontend/bookinfo-v1-mesh.yaml

# create sleep app in default namespace to run curl commands from
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/frontend/sleep-default-ns.yaml

### check bookinfo-v1 deployment status
../../tools/wait-for-rollout.sh deployment productpage-v1 bookinfo-v1 10

# check sleep deployment status 
../../tools/wait-for-rollout.sh deployment sleep default 5

# curl 
for i in {1..10}; do kubectl exec deploy/sleep -n default -- curl http://productpage.bookinfo-v1:9080/productpage; done

for i in {1..10}; do curl http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage; done

# get istio URL
echo for kind deployments:
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
echo for cloud deployments:
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"