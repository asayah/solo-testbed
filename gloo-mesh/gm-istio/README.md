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

## install gloo mesh istio
Once argocd is installed, simply run the script below in order to deploy this argo [app-of-apps demo](https://github.com/ably77/solo-testbed-apps/tree/main/argo-apps/environments/gloo-mesh-istio) for gloo mesh istio
```
./install-gm-istio-aoa.sh ${CONTEXT}
```

## port-forward commands
Grafana:
```
kubectl port-forward svc/grafana -n istio-system 3000:3000
```

Kiali:
```
kubectl port-forward deployment/kiali -n istio-system 20001:20001
```

Gloo Mesh:
```
kubectl port-forward svc/dashboard -n gloo-mesh 8090:8090
```