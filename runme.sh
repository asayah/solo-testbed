#!/bin/bash

# create argocd namespace
kubectl create namespace argocd

# deploy argocd
until kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml; do sleep 2; done

# wait for argo cluster rollout
./scripts/wait-for-rollout.sh deployment argocd-server argocd 10

# port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# get the argocd password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D && echo

# open port-forward
open http://localhost:8080