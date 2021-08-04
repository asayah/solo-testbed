# gloo-mesh

# Prerequisites
- Kubernetes clusters up and authenticated to kubectl
- argocd
- Enterprise Trial License Key

## argocd
If you have not yet installed argocd, navigate to the `argocd` directory and follow the instructions to install argocd

## kubectl contexts
Since we will potentially be using multiple clusters/contexts, it is useful to rename your contexts for a better experience
```
kubectl config get-contexts
kubectl config rename-contexts <current_name> <new_name>
export CONTEXT=<new_name>
```

### adding the enterprise license key
When deploying gloo-mesh enterprise the script looks for a manifest `gloo-mesh-ee-helm.yaml`. We need to modify this manifest `license_key: <INSERT_LICENSE_KEY_HERE>` to a valid key.

When complete, the manifest will look similar to below:
```
source:
    chart: gloo-mesh-enterprise
    helm:
      values: |
        licenseKey: ABCDEFG
    repoURL: https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise
```

## install gloo mesh
Once argocd is installed, simply run the script below in order to deploy gloo-mesh oss or gloo-mesh ee
```
./install-gloo-mesh.sh ${CONTEXT} ${FEATURES}
```

An example deploy would be as follows:
```
./install-gloo-mesh.sh cluster1 ee
```
This command above will deploy gloo-mesh ee in cluster1

### install meshctl
```
curl -sL https://run.solo.io/meshctl/install | sh -
export PATH=$HOME/.gloo-mesh/bin:$PATH
```

### register current cluster istio deployment with gloo mesh using meshctl (useful for kind or local deployments)
```
SVC=$(kubectl --context ${CONTEXT} -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
meshctl cluster register --mgmt-context=${CONTEXT} --remote-context=${CONTEXT} --relay-server-address=$SVC:9900 enterprise cluster1 --cluster-domain cluster.local
```

### (optional) register a second cluster and istio deployment with gloo mesh using meshctl
First set your contexts correctly, for example:
```
$ k config get-contexts
CURRENT   NAME       CLUSTER      AUTHINFO     NAMESPACE
          cluster1   kind-kind1   kind-kind1   
*         cluster2   kind-kind2   kind-kind2   
```

So my context variables would be:
```
export MGMT=cluster1
export CLUSTER2=cluster2
```

Then run:
```
SVC=$(kubectl --context ${MGMT} -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER2} --relay-server-address=$SVC:9900 enterprise cluster2 --cluster-domain cluster.local
```

### access gloo mesh dashboard
access gloo mesh dashboard at `http://localhost:8090`:
```
kubectl port-forward -n gloo-mesh svc/dashboard 8090
```