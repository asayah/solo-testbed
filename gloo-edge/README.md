# Prerequisites
- Kubernetes clusters up and authenticated to kubectl
- argocd

## argocd
If you have not yet installed argocd, navigate to the `argocd` directory and follow the instructions to install argocd

## kubectl contexts
Since we will potentially be using multiple clusters/contexts, it is useful to rename your contexts for a better experience
```
kubectl config get-contexts
kubectl config rename-contexts <current_name> <new_name>
export CONTEXT=<new_name>
```

## install gloo edge
Once argocd is installed, simply run the script below in order to deploy this argo [app-of-apps demo](https://github.com/ably77/solo-testbed-apps/tree/main/argo-apps/environments/gloo-edge) for gloo-edge
```
./install-gloo-edge-aoa.sh ${CONTEXT}
```