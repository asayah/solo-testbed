# solo-testbed
This repo is meant to demonstrate how to deploy and manage solo.io products with a declarative GitOps based approach using argoCD
 
## Prerequisites
- Kubernetes clusters up and authenticated to kubectl

### kubectl contexts
Since we will potentially be using multiple clusters/contexts, it is useful to rename your contexts for a better experience
```
kubectl config get-contexts
kubectl config rename-contexts <current_name> <new_name>
export CONTEXT=<new_name>
```

## Bootstrap argoCD
argoCD is required to be deployed on each cluster if you want to deploy the applications below

To install argoCD:
```
cd argocd
install-argocd.sh ${CONTEXT}
```

## Deploy argoCD apps

To install gloo-edge app-of-app:
```
cd gloo-edge
./install-gloo-edge-aoa.sh ${CONTEXT}
```

To install gloo-mesh:
```
cd gloo-mesh
./install-gloo-mesh-oss.sh ${CONTEXT}
./install-gloo-mesh-ee.sh ${CONTEXT}
```

To install istio app-of-app:
```
cd istio
./install-istio-aoa.sh ${CONTEXT}
```

To install istioinaction workshop app-of-app: 
```
cd istioinaction-workshop
./install-istioinaction-aoa.sh ${CONTEXT}
```

### access argoCD UI
using port forward:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

#### argoCD credentials
Access the argoCD UI at (http://localhost:8080) with the credentials `admin/solo.io`

### gloo-mesh

Register clusters (CLI Method):
```
SVC=$(kubectl --context ${MGMT} -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER1} --relay-server-address=$SVC:9900 enterprise cluster1 --cluster-domain cluster.local
meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER2} --relay-server-address=$SVC:9900 enterprise cluster2 --cluster-domain cluster.local
```

access gloo mesh dashboard at `http://localhost:8090`:
```
kubectl --context ${MGMT} port-forward -n gloo-mesh svc/dashboard 8090
```

### access bookinfo on istio-ingressgateway
Access the bookinfo app with the command below:
```
echo for kind deployments:
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
echo for cloud deployments:
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"
```

### access bookinfo app on gloo-edge
```
echo for kind deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"
echo for cloud deployments:
echo access app here: "http://$(kubectl --context ${CONTEXT} -n gloo-system get svc gateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"
```

### port-forward for envoy admin API (gloo edge)
```
kubectl port-forward -n gloo-system deploy/gateway-proxy 19000:19000
```

### important curl commands
```
Header match:
curl -H "Host: petstore.solo.io" -H "header1: value1" $(glooctl proxy url)/all-pets -v

Exact path match:
curl -H "Host: petstore.solo.io" $(glooctl proxy url)/all-pets -v

Prefix path match:
curl -H "Host: petstore.solo.io" $(glooctl proxy url)/foo -v

httpbin curl:
curl -H "Host: httpbin.solo.io" $(glooctl proxy url)/headers -v

bookinfo curl:
curl $(glooctl proxy url)/productpage -v 
```