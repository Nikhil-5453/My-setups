#INSTALL HELM:
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

#INSTALL ARGO CD USING HELM
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm repo update

read -p "Enter namespace to create: " NS
read -p "Enter name for repo: " RP

kubectl create namespace $NS
helm install $RP argo-cd/argo-cd -n $NS
kubectl get all -n $NS


#EXPOSE ARGOCD SERVER:
kubectl patch svc argocd-server -n $NS -p '{"spec": {"type": "LoadBalancer"}}'
yum install jq -y
sleep 10
kubectl get svc -n $NS
LB_IP=$(kubectl get svc argocd-server -n "$NS" -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname // .status.loadBalancer.ingress[0].ip // empty')
echo "LB_external_ip:: $LB_IP"
# nohup kubectl port-forward service/argocd-server -n "$NS" "${NODE_PORT}:443" --address 0.0.0.0 > argocd-port-forward.log 2>&1 &
#The above command will provide load balancer URL to access ARGO CD


#TO GET ARGO CD PASSWORD:
ARGO_PWD=$(kubectl -n "$NS" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Username: admin"
echo "Password: $ARGO_PWD"

s