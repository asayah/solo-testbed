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

# uninstall all argo apps
kubectl --context ${CONTEXT} delete applications -n argocd --all

# delete namespaces
kubectl --context ${CONTEXT} delete ns bookinfo-v1
kubectl --context ${CONTEXT} delete ns bookinfo-beta
kubectl --context ${CONTEXT} delete ns gloo-system
kubectl --context ${CONTEXT} delete ns gloo-mesh
kubectl --context ${CONTEXT} delete ns istio-system
kubectl --context ${CONTEXT} delete ns istio-operator
kubectl --context ${CONTEXT} delete ns knative-operator
kubectl --context ${CONTEXT} delete ns knative-serving
kubectl --context ${CONTEXT} delete ns knative-eventing

# delete CRDs
# gloo-mesh
kubectl --context ${CONTEXT} delete crd accesslogrecords.observability.enterprise.mesh.gloo.solo.io accesspolicies.networking.mesh.gloo.solo.io certificaterequests.certificates.mesh.gloo.solo.io destinations.discovery.mesh.gloo.solo.io issuedcertificates.certificates.mesh.gloo.solo.io kubernetesclusters.multicluster.solo.io meshes.discovery.mesh.gloo.solo.io podbouncedirectives.certificates.mesh.gloo.solo.io rolebindings.rbac.enterprise.mesh.gloo.solo.io roles.rbac.enterprise.mesh.gloo.solo.io settings.settings.mesh.gloo.solo.io trafficpolicies.networking.mesh.gloo.solo.io virtualdestinations.networking.enterprise.mesh.gloo.solo.io virtualmeshes.networking.mesh.gloo.solo.io wasmdeployments.networking.enterprise.mesh.gloo.solo.io workloads.discovery.mesh.gloo.solo.io xdsconfigs.xds.agent.enterprise.mesh.gloo.solo.io
# istio
kubectl --context ${CONTEXT} delete crd authorizationpolicies.security.istio.io destinationrules.networking.istio.io envoyfilters.networking.istio.io gateways.networking.istio.io istiooperators.install.istio.io peerauthentications.security.istio.io requestauthentications.security.istio.io serviceentries.networking.istio.io sidecars.networking.istio.io virtualservices.networking.istio.io workloadentries.networking.istio.io workloadgroups.networking.istio.io
# gloo-edge
kubectl --context ${CONTEXT} delete crd proxies.gloo.solo.io settings.gloo.solo.io upstreamgroups.gloo.solo.io upstreams.gloo.solo.io authconfigs.enterprise.gloo.solo.io gateways.gateway.solo.io ratelimitconfigs.ratelimit.solo.io routetables.gateway.solo.io virtualservices.gateway.solo.io 

