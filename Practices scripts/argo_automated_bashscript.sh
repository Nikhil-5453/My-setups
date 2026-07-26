#!/bin/bash

# Using MINIKUBE cluster.
# For Minikube follow commands except for service expose., need to do port-foward since cant create a LB for single node.

# Install HELM as pre-requiste

echo "**======================== Installing HELM =========================**"
if ! command -v helm &> /dev/null; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm -f get_helm.sh
else
    echo "Helm already installed, skipping."
fi


# Installing ARGO-CD using helm repos

echo "**====================== INSTALL ARGO CD USING HELM =====================**"
read -p "Enter namespace to create: " NS
read -p "Enter name for repo: " RP

# Idempotent namespace creation
kubectl get namespace "$NS" &> /dev/null || kubectl create namespace "$NS"
kubectl config set-context --current --namespace=$NS
helm repo add $RP https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd $RP/argo-cd \
    --namespace "$NS" \
    --wait --timeout 2m


echo "**========================= EXPOSE ARGOCD SERVER =======================**"

# command -v jq &> /dev/null || sudo yum install jq -y

# echo "Enter type of (NodePort / LoadBalance)...."
# echo "For KOPS cluster choose 'LB'; For Minikube cluster choose 'NP'"
# read -p "Enter type:: " $ST

# kubectl patch svc argocd-server -n "$NS" -p '{"spec": {"type": $ST}}'

# Pull the actual assigned NodePort for the HTTPS port (443)
# NODE_PORT=$(kubectl get svc argocd-server -n "$NS" -o json | jq --raw-output '.spec.ports[] | select(.port==443) | .$ST')

# echo "ArgoCD server NodePort: $NODE_PORT"

# Forward that NodePort on all interfaces so it's reachable remotely (e.g. over SSH/EC2)
# Runs in background; use nohup so it survives the shell/SSH session ending
# nohup kubectl port-forward service/argocd-server -n "$NS" "${NODE_PORT}:443" --address 0.0.0.0 > argocd-port-forward.log 2>&1 &

# echo "Port-forward started in background (PID $!). Logs: argocd-port-forward.log"


command -v jq &> /dev/null || sudo yum install jq -y

echo "Enter type of service (NP / LB):"
echo "For KOPS/cloud cluster choose 'LB'; for Minikube choose 'NP'"
read -p "Enter type:: " ST

case "$ST" in
    NP)
        SVC_TYPE="NodePort"
        ;;
    LB)
        SVC_TYPE="LoadBalancer"
        ;;
    *)
        echo "Invalid choice '$ST'. Must be NP or LB."
        exit 1
        ;;
esac

kubectl patch svc argocd-server -n "$NS" -p "{\"spec\": {\"type\": \"$SVC_TYPE\"}}"

if [ "$SVC_TYPE" == "NodePort" ]; then
    # Pull the actual assigned NodePort for the HTTPS port (443)
    NODE_PORT=$(kubectl get svc argocd-server -n "$NS" -o json | \
        jq --raw-output '.spec.ports[] | select(.port==443) | .nodePort')
    echo "ArgoCD server NodePort: $NODE_PORT"

    # Forward that NodePort on all interfaces so it's reachable remotely (e.g. over SSH/EC2)
    # Runs in background; use nohup so it survives the shell/SSH session ending
    nohup kubectl port-forward service/argocd-server -n "$NS" \
        "${NODE_PORT}:443" --address 0.0.0.0 > argocd-port-forward.log 2>&1 &

    echo "Port-forward started in background (PID $!). Logs: argocd-port-forward.log"
    echo "Access at: https://<node-ip>:${NODE_PORT}"
else
    # LoadBalancer: wait for the cloud provider to assign an address
    echo "Waiting for LoadBalancer to be provisioned..."
    for i in {1..30}; do
        LB_HOST=$(kubectl get svc argocd-server -n "$NS" -o json | \
            jq --raw-output '.status.loadBalancer.ingress[0].hostname // .status.loadBalancer.ingress[0].ip // empty')
        [ -n "$LB_HOST" ] && break
        sleep 10
    done

    if [ -z "$LB_HOST" ]; then
        echo "LoadBalancer address not yet assigned. Check manually with:"
        echo "  kubectl get svc argocd-server -n $NS"
    else
        echo "ArgoCD server LoadBalancer address: $LB_HOST"
        echo "Access at: https://$LB_HOST"
    fi
fi




# Extact the admin Password for argoCD server web access.
echo "**==========================ARGO CD PASSWORD============================**"
until kubectl -n "$NS" get secret argocd-initial-admin-secret &> /dev/null; do
    echo "Waiting for argocd-initial-admin-secret to be created..."
    sleep 5
done

ARGO_PWD=$(kubectl -n "$NS" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Username: admin"
echo "Password: $ARGO_PWD"

echo "Installation and setup of ARGO-CD completed"
echo "------ Access at: https://<node-ip>:${NODE_PORT}  (or the EC2 public IP if forwarding externally) --------"