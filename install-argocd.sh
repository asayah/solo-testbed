#!/bin/bash

# create argocd namespace
kubectl create namespace argocd

# deploy argocd
until kubectl apply -k https://github.com/ably77/solo-testbed-apps.git/kustomize/instances/overlays/platform/argocd/; do sleep 2; done

# wait for argo cluster rollout
./scripts/wait-for-rollout.sh deployment argocd-server argocd 10

# bcrypt(password)=$2a$10$79yaoOg9dL5MO8pn8hGqtO4xQDejSEVNWAGQR268JHLdrCw6UCYmy
# password: solo.io
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$79yaoOg9dL5MO8pn8hGqtO4xQDejSEVNWAGQR268JHLdrCw6UCYmy",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

# port forward
#kubectl port-forward svc/argocd-server -n argocd 8080:443

# get the argocd password
#kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# open port-forward
#open http://localhost:8080