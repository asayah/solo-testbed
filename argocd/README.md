# Prerequisites
- Kubernetes clusters up and authenticated to kubectl

## kubectl contexts
Since we will potentially be using multiple clusters/contexts, it is useful to rename your contexts for a better experience
```
kubectl config get-contexts
kubectl config rename-contexts <current_name> <new_name>
export CONTEXT=<new_name>
```

## install argocd
If you have done the above, just simply run the script to install argocd
```
./install-argocd.sh ${CONTEXT}
```

### access argoCD UI
using port forward:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```