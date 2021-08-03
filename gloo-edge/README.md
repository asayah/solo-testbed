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

### register a second cluster to gloo-fed
```
export CLUSTER_NAME=
export CONTEXT=
glooctl cluster register --cluster-name ${CLUSTER_NAME} --remote-context ${CONTEXT} --remote-namespace gloo-system
```

### port-forward for gloo-fed console
```
kubectl port-forward svc/gloo-fed-console -n gloo-system 8090:8090
```

### port-forward for envoy admin API (gloo edge)
```
kubectl port-forward -n gloo-system deploy/gateway-proxy 19000:19000
```

### access bookinfo app on gloo-edge
If the bookinfo app is deployed:
```
echo for kind deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
echo for cloud deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"
```
