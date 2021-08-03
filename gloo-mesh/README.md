# gloo-mesh

### Register clusters (CLI Method):
```
SVC=$(kubectl --context ${MGMT} -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER1} --relay-server-address=$SVC:9900 enterprise cluster1 --cluster-domain cluster.local
meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER2} --relay-server-address=$SVC:9900 enterprise cluster2 --cluster-domain cluster.local
```

access gloo mesh dashboard at `http://localhost:8090`:
```
kubectl --context ${MGMT} port-forward -n gloo-mesh svc/dashboard 8090
```