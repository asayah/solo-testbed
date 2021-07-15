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

# create argocd operator
echo now deploying argoCD
until kubectl apply -k https://github.com/ably77/openshift-testbed-apps/kustomize/instances/overlays/operators/namespaced-operators/argocd-operator; do sleep 2; done

# wait for argo cluster rollout
../scripts/wait-for-rollout.sh deployment argocd-server argocd 10