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

# create argocd namespace
kubectl --context ${CONTEXT} create namespace argocd

# deploy argocd
until kubectl --context ${CONTEXT} apply -k https://github.com/ably77/solo-testbed-apps.git/kustomize/instances/overlays/platform/argocd/; do sleep 2; done

# wait for argo cluster rollout
../scripts/wait-for-rollout.sh deployment argocd-server argocd 10

# bcrypt(password)=$2a$10$79yaoOg9dL5MO8pn8hGqtO4xQDejSEVNWAGQR268JHLdrCw6UCYmy
# password: solo.io
kubectl --context ${CONTEXT} -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$79yaoOg9dL5MO8pn8hGqtO4xQDejSEVNWAGQR268JHLdrCw6UCYmy",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

# port forward
#kubectl --context ${CONTEXT} port-forward svc/argocd-server -n argocd 8080:443

# get the argocd password
#kubectl --context ${CONTEXT} -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# open port-forward
#open http://localhost:8080