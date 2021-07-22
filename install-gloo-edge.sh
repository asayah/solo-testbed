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

# deploy gloo-edge-oss-helm argo application
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/gloo-edge/gloo-edge-oss-helm.yaml

### check gloo-edge deployment status
until kubectl --context ${CONTEXT} get ns gloo-system
do
  sleep 1
done

until [ $(kubectl --context ${CONTEXT} -n gloo-system get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the gloo-system pods to become ready"
  sleep 1
done

# deploy bookinfo-v1 app
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/frontend/bookinfo-v1-edge.yaml

# deploy bookinfo-v2 app
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/frontend/bookinfo-beta-edge.yaml

# deploy virtualservice
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/gloo-edge/virtualservices/bookinfo-vs.yaml

# get bookinfo URL
echo for kind deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
echo for cloud deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"
