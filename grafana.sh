# Install grafana from helm-charts

# First install metric server as given in promethus.sh -> install helm -> install prometheus -> then Install GRAFANA.

echo "**--------- Downloading Grafana repo from helm-chart ------------**"
helm repo add grafana-repo https://grafana.github.io/helm-charts
helm repo update
helm repo list

# Install Grsfana from repo.
echo "**----------- Installing grafana from repo --------------**"
kubectl create ns grafana-ns
helm install grafana grafana-repo/grafana -n grafana-ns --set persistence.storageClassName="gp2"  --set persistence.enabled=true --set adminPassword='EKS!sAWSome' --set service.type=LoadBalancer
# Change this 'persistence.storageClassName' as per storageClassName for volume (or) create one volume with required classname.
# check storageClassName by command: kubectl get storageClass

echo " Here, grafana installed and service create on LB; if its on MINIKUBE cluster
       don't forget to port-forward the NodePort
       cmd: nohup kubectl port-forward -n grafana-ns svc/grafana 31898:80 --address 0.0.0.0 >> grafana-port.log 2>&1 &
       this will keep running service background"

echo "**------------- verify grafana resources -------------**"
kubectl get all -n grafana-ns
       
