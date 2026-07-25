# Using KOPS cluster.
# For Minikube follow commands except for service expose., need to do port-foward since cant create a LB for single node.

# Install HELM as pre-requiste
echo "**======================== Intalling HELM =========================**"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sh get_helm.sh


# Installing ARGO-CD using helm repos
echo "**====================== INSTALL ARGO CD USING HELM =====================**"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# Creating a service in k8s cluster for ArgoCD
echo "**========================= EXPOSE ARGOCD SERVER =======================**"
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
yum install jq -y
export ARGOCD_SERVER='kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname''
echo $ARGOCD_SERVER
kubectl get svc argocd-server -n argocd -o json | jq --raw-output .status.loadBalancer.ingress[0].hostname
#The above command will provide load balancer URL to access ARGO CD

# For MINIKUBE cluster need to pulish the port to container
  # -> 'argocd-server' is name of service by default it would create a clusterIP service.
  #     but in above commands service creation its converted to LB. however minkube won't create ** LB ** need to convert as ** NodePort ** 

# minikube cmds: (uncomment and use)
# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# kubectl port-forward service/argocd-server -n argons 31516:443 --address 0.0.0.0 &


# Extact the admin Password for argoCD server web access.
echo "**==========================ARGO CD PASSWORD============================**"
export ARGO_PWD=$(kubectl -n argons get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "paswword is::  $ARGO_PWD"
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
# The above command to provide password to access argo cd

echo "Inatallation and setup of ARGO-CD completed"
echo "
echo "------Acesss as https://<node-ip>:<node-port-ip>--------"



