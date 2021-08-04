#!/bin/bash

CONTEXT=$1
FEATURES=$2

### check to make sure that arguments were set before taking off
if [[ ${CONTEXT} == "" ]] || [[ ${FEATURES} == "" ]]
then
  echo "Missing arguments. Proper usage is ./install-script.sh <context> <oss/ee>"
  echo "example:"
  echo "./install-gloo-edge-aoa.sh cluster1 oss"
  echo "would install open source gloo edge on cluster1"
  exit 1
else
  echo "Beginning install on context ${CONTEXT}...."
fi

# use context
kubectl config use-context ${CONTEXT}

# for ee deploy
if [[ ${FEATURES} == "ee" ]]
  then
  # check to see if license key has been provided
  LICENSE=$(cat gloo-mesh-ee-helm.yaml | grep licenseKey: | awk '{ print $2 }')
  if [[ ${LICENSE} == "<INSERT_LICENSE_KEY_HERE>" ]]
    then
    echo "no license key provided, please replace <INSERT_LICENSE_KEY_HERE> value in the gloo-mesh-ee-helm.yaml to continue"
    exit 1
  fi   
  # deploy gloo-mesh-ee argo-app
  kubectl --context ${CONTEXT} create -f gloo-mesh-ee-helm.yaml
  ### check gloo-mesh deployment status
  ../tools/wait-for-rollout.sh deployment enterprise-networking gloo-mesh 10
  ### install meshctl 
  curl -sL https://run.solo.io/meshctl/install | sh -
  export PATH=$HOME/.gloo-mesh/bin:$PATH
  ### register current cluster istio deployment with gloo mesh using meshctl
  SVC=$(kubectl --context ${CONTEXT} -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  meshctl cluster register --mgmt-context=${CONTEXT} --remote-context=${CONTEXT} --relay-server-address=$SVC:9900 enterprise cluster1 --cluster-domain cluster.local
fi

# for oss deploy
if [[ ${FEATURES} == "oss" ]]
  then
  # deploy gloo-mesh-oss-helm argo application
  kubectl --context ${CONTEXT} create -f https://raw.githubusercontent.com/ably77/solo-testbed-apps/main/argo-apps/instances/platform/gloo-mesh/gloo-mesh-oss-helm.yaml
  ### check gloo-mesh deployment status
  ../tools/wait-for-rollout.sh deployment networking gloo-mesh 10
fi

### check to see if components are deployed
kubectl --context ${CONTEXT} get pods -n gloo-mesh
