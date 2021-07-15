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

# add anyuid for every project used by istio
oc --context ${CONTEXT} adm policy add-scc-to-group anyuid system:serviceaccounts:istio-system
oc --context ${CONTEXT} adm policy add-scc-to-group anyuid system:serviceaccounts:istio-operator
oc --context ${CONTEXT} adm policy add-scc-to-group anyuid system:serviceaccounts:bookinfo-v1
oc --context ${CONTEXT} adm policy add-scc-to-group anyuid system:serviceaccounts:bookinfo-beta

# download istio 1.10.2
#export ISTIO_VERSION=1.10.2
#curl -L https://istio.io/downloadIstio | sh -

# deploy istio-operator argo application
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/istio/istio-operator.yaml

### check istio-operator deployment status
../scripts/wait-for-rollout.sh deployment istio-operator istio-operator 10

# deploy istio argo application (openshift profile)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/istio/profiles/istio-openshift.yaml

### check istio deployment status
../scripts/wait-for-rollout.sh deployment istio-ingressgateway istio-system 10

### deploy bookinfo app configured for ocp
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/frontend/openshift/bookinfo-v1.yaml

### check bookinfo-v1 deployment status
../scripts/wait-for-rollout.sh deployment productpage-v1 bookinfo-v1 10

# get istio URL
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"