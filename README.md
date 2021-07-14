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

### bookinfo
Access the bookinfo app with the command below:
```
echo access bookinfo app here: "http://$(kubectl --context ${CONTEXT} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/productpage"

```