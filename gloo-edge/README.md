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

## features (ee/oss)
The install script requires you to define whether you want to install open source gloo-edge or gloo edge enterprise by providing an additional argument `ee/oss` to the install script. If choosing `oss` you can continue forward to the next section, but if you are selecting `ee` then follow the steps below to add your enterprise license key

### adding the enterprise license key
When deploying gloo-edge enterprise the script looks for a manifest located here: `non-aoa/gloo-edge-ee-helm.yaml`. We need to modify this manifest `license_key: <INSERT_LICENSE_KEY_HERE>` to a valid key.

When complete, the manifest will look similar to below:
```
source:
    chart: gloo-ee
    helm:
      values: |
        license_key: ABCDEFG     
    repoURL: http://storage.googleapis.com/gloo-ee-helm
```

## install gloo edge
Once argocd is installed, simply run the script below in order to deploy this argo [app-of-apps demo](https://github.com/ably77/solo-testbed-apps/tree/main/argo-apps/environments/gloo-edge-oss) for gloo-edge-oss or this argo [app-of-apps demo](https://github.com/ably77/solo-testbed-apps/tree/main/argo-apps/environments/gloo-edge-ee) for gloo-edge-ee
```
./install-gloo-edge-enterprise-aoa.sh ${CONTEXT} ${FEATURES}
```

An example deploy would be as follows:
```
./install-gloo-edge-aoa.sh cluster1 fed
```
This command above will deploy gloo-edge ee in cluster1 with gloo-fed enabled

### register a second cluster to gloo-fed
If you have a second cluster you would like to register to the gloo-fed console, follow the steps below

#### IMPORTANT: set correct variables for contexts
For example
```
export MGMT_CONTEXT=cluster1
export REMOTE_CONTEXT=cluster2
```

Then register the remote cluster
```
kubectl config use-context ${MGMT_CONTEXT}
glooctl cluster register --cluster-name ${REMOTE_CONTEXT} --remote-context ${REMOTE_CONTEXT} --remote-namespace gloo-system
```

**Note:** The glooctl command below needs to be run where the gloo fed management plane exists

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
