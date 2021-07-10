#!/bin/bash

# create argocd namespace
kubectl create namespace argocd

# deploy argocd
until kubectl apply -k https://github.com/ably77/solo-testbed-apps.git/kustomize/instances/overlays/platform/argocd/; do sleep 2; done

# wait for argo cluster rollout
./scripts/wait-for-rollout.sh deployment argocd-server argocd 10

# port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# get the argocd password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# open port-forward
open http://localhost:8080

# deploy gloo-edge-oss-helm argo application
kubectl create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/gloo-edge/gloo-edge-oss-helm.yaml

### check gloo deployment status
until kubectl get ns gloo-system
do
  sleep 1
done

until [ $(kubectl -n gloo-system get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the gloo-system pods to become ready"
  sleep 1
done

# deploy bookinfo-v1 app
kubectl create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/frontend/bookinfo-v1-app.yaml

# deploy bookinfo-v2 app
kubectl create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/frontend/bookinfo-beta-app.yaml

# deploy virtualservice
kubectl create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/gloo-edge/virtualservices/bookinfo-vs.yaml