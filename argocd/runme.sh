# create argocd namespace
kubectl create namespace argocd

# deploy argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# get the argocd password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D && echo