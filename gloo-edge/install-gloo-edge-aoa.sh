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

# deploy gloo-edge app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/edge/meta/meta-gloo-edge.yaml

### check gloo-edge deployment status
../tools/wait-for-rollout.sh deployment gateway gloo-system 10

# deploy frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/frontend/meta/meta-frontend-apps.yaml

# deploy virtualservices app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/gloo-edge/virtualservice/meta/meta-virtualservices.yaml

# check bookinfo-v1 deployment status 
../tools/wait-for-rollout.sh deployment productpage-v1 bookinfo-v1 5

# check bookinfo-beta deployment status 
../tools/wait-for-rollout.sh deployment productpage-v1 bookinfo-beta 5

# get bookinfo URL
echo for kind deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
echo for cloud deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"
