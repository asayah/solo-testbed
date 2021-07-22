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

# deploy kube-prometheus (helm) argo application 
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/observability/kube-prometheus-15-2-0.yaml

# check kube grafana deployment status as this usually completes last
../scripts/wait-for-rollout.sh deployment prometheus-operator-helm-grafana prometheus 10

# deploy istio grafana monitoring dashboard config
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/observability/istio-monitoring.yaml

# deploy kiali operator (helm) argo application 
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/observability/kiali-operator-1-29-1.yaml

# deploy kiali instance argo application 
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/observability/kiali-instance-1-29-1.yaml

# check kiali deployment status 
../scripts/wait-for-rollout.sh deployment kiali-operator-helm istio-system 10

# this is for regular deployment of istio
# create a label in the default namespace with istio-injection=enabled and deploy httpbin app
kubectl --context ${CONTEXT} label ns httpbin istio-injection=enabled
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/frontend/httpbin-app.yaml

# create sleep app in default namespace to run curl commands from
kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/frontend/sleep-default-ns.yaml

# check httpbin deployment status 
../scripts/wait-for-rollout.sh deployment httpbin httpbin 10

# check sleep deployment status 
../scripts/wait-for-rollout.sh deployment sleep default 5

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
