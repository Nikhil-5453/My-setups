#INSTALL HELM:
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

#INSTALL ARGO CD USING HELM
read -p "Enter namespace to create: " NS
read -p "Enter name for repo: " RP

kubectl create namespace $NS
helm repo add $RP https://argoproj.github.io/argo-helm
helm repo update

read -p "Enter Release name to install argocd: " RS
helm install $RS $RP/argo-cd -n $NS
kubectl get all -n $NS


#EXPOSE ARGOCD SERVER:
kubectl patch svc $RS-argocd-server -n $NS -p '{"spec": {"type": "NodePort"}}'
yum install jq -y
sleep 10
NODE_PORT=$(kubectl get svc $RS-argocd-server -n "$NS" -o json | jq --raw-output '.spec.ports[] | select(.port==443) | .nodePort')
kuebctl get svc -n $NS
echo "ArgoCD server NodePort: $NODE_PORT"
  
nohup kubectl port-forward service/$RS-argocd-server -n "$NS" "${NODE_PORT}:443" --address 0.0.0.0 > argocd-port-forward.log 2>&1 &
#The above command will provide load balancer URL to access ARGO CD


#TO GET ARGO CD PASSWORD:
ARGO_PWD=$(kubectl -n "$NS" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Username: admin"
echo "Password: $ARGO_PWD"