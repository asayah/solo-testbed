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

# Install operator app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/operator/meta/meta-operator-app.yaml

# wait for important operators
### check istio-operator deployment status
../tools/wait-for-rollout.sh deployment istio-operator istio-operator 10

# Install platform app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/platform/meta/meta-platform-app.yaml

# wait for platform
### check istio control plane deployment status
../tools/wait-for-rollout.sh deployment istiod-1-9-5 istio-system 10

# check kube grafana deployment status as this usually completes last
../tools/wait-for-rollout.sh deployment prometheus-operator-helm-grafana prometheus 10

# Install frontend app-of-apps
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/frontend/meta/meta-frontend-app.yaml

### check istio ingress gateway deployment status
../tools/wait-for-rollout.sh deployment istio-ingressgateway istio-ingress 10

# wait for apps
### check web-api deployment status
../tools/wait-for-rollout.sh deployment web-api web-api 5

# deploy httpbin-injected application (istioinaction workshop)
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/environments/istioinaction/injected-httpbin-app.yaml

### check httpbin-injected deployment status
../tools/wait-for-rollout.sh deployment httpbin httpbin 5

# check sleep deployment status 
../tools/wait-for-rollout.sh deployment sleep default 5

# curl 
for i in {1..10}; do kubectl exec deploy/sleep -n default -- curl http://httpbin.httpbin:8000/headers; done

# port-forward commands
echo To reach Grafana UI:
echo kubectl port-forward svc/prometheus-operator-helm-grafana -n prometheus 3000:80
echo
echo To reach Prometheus UI:
echo kubectl port-forward svc/prometheus-operator-helm-k-prometheus -n prometheus 9090
echo
echo To reach Kiali UI:
echo kubectl port-forward svc/kiali -n istio-system 20001
echo