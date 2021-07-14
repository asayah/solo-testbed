#!/bin/bash

CONTEXT=$1

### check to make sure that arguments were set before taking off
if [[ ${CONTEXT} == "" ]]
then
  echo "Proper usage is ./install-script.sh <context>"
  echo "example:"
  echo "./install-argocd.sh mgmt"
  echo "would install argocd on the mgmt context"
  exit 1
else
  echo "Beginning install on context ${CONTEXT}...."
fi

# use context
kubectl config use-context ${CONTEXT}

# install meshctl CLI
export GLOO_MESH_VERSION=v1.0.9
curl -sL https://run.solo.io/meshctl/install | sh -
export PATH=$HOME/.gloo-mesh/bin:$PATH

# deploy gloo-mesh-ee-helm argo application
# creating from YAML because of sensitive values (license key)
kubectl --context ${CONTEXT} create -f gloo-mesh-ee-helm.yaml

### check gloo-edge deployment status
./scripts/wait-for-rollout.sh deployment enterprise-networking gloo-mesh 10

# register clusters (CLI Method)
#SVC=$(kubectl --context ${MGMT} -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
#meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER1} --relay-server-address=$SVC:9900 enterprise cluster1 --cluster-domain cluster.local
#meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER2} --relay-server-address=$SVC:9900 enterprise cluster2 --cluster-domain cluster.local

# register clusters (declarative)


# access gloo mesh dashboard at localhost:8090
#kubectl --context ${CONTEXT} port-forward -n gloo-mesh svc/dashboard 8090