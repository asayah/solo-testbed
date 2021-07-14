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

# delete CRDs
# gloo-mesh
kubectl --context ${CONTEXT} delete crd accesslogrecords.observability.enterprise.mesh.gloo.solo.io accesspolicies.networking.mesh.gloo.solo.io certificaterequests.certificates.mesh.gloo.solo.io destinations.discovery.mesh.gloo.solo.io issuedcertificates.certificates.mesh.gloo.solo.io kubernetesclusters.multicluster.solo.io meshes.discovery.mesh.gloo.solo.io podbouncedirectives.certificates.mesh.gloo.solo.io rolebindings.rbac.enterprise.mesh.gloo.solo.io roles.rbac.enterprise.mesh.gloo.solo.io settings.settings.mesh.gloo.solo.io trafficpolicies.networking.mesh.gloo.solo.io virtualdestinations.networking.enterprise.mesh.gloo.solo.io virtualmeshes.networking.mesh.gloo.solo.io
# argocd
kubectl --context ${CONTEXT} delete crd applications.argoproj.io appprojects.argoproj.io
# istio
kubectl --context ${CONTEXT} delete crd authorizationpolicies.security.istio.io destinationrules.networking.istio.io envoyfilters.networking.istio.io gateways.networking.istio.io istiooperators.install.istio.io peerauthentications.security.istio.io requestauthentications.security.istio.io serviceentries.networking.istio.io sidecars.networking.istio.io virtualservices.networking.istio.io workloadentries.networking.istio.io workloadgroups.networking.istio.io

