# solo-testbed
This repo is meant to demonstrate how to deploy and manage solo.io products with a declarative GitOps based approach using argoCD
 
## Prerequisites
- Kubernetes clusters up and authenticated to kubectl

## Bootstrap argoCD
argoCD is required to be deployed on each cluster if you want to deploy the applications below

To install argoCD:
```
./install-argocd.sh <context>
```

## Deploy argoCD apps

To install gloo-edge:
```
./install-gloo-edge.sh <context>
```

To install gloo-mesh:
```
./install-gloo-mesh.sh <context>
```

To install istio:
```
./install-istio.sh <context>
```