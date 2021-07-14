#!/bin/bash

# download istio 1.10.2
#export ISTIO_VERSION=1.10.2
#curl -L https://istio.io/downloadIstio | sh -

# deploy istio-operator argo application
kubectl create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/istio/istio-operator.yaml

### check istio-operator deployment status
./scripts/wait-for-rollout.sh deployment istio-operator istio-operator 10

# deploy istio argo application
kubectl create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/platform/istio/workshop/cluster1.yaml

### check istio deployment status
./scripts/wait-for-rollout.sh deployment istio-ingressgateway istio-system 10

### deploy bookinfo app
kubectl create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/frontend/bookinfo-v1-mesh.yaml

### check bookinfo-v1 deployment status
./scripts/wait-for-rollout.sh deployment productpage-v1 bookinfo-v1 10

# get istio URL
echo access bookinfo app here: "http://$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
