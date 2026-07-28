# Install helm first. To make prometheus set-up easily by using helm-charts.

# Install metric server in cluster to get metrices from all resources in clsuter to prometheus
echo "**---------- Installing Metric-server ------------**"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Download Repo's for Prometheus from helm-charts
echo "**-----------Dowmloading repo Prometheus ------------**"
helm repo add prometheus-repo https://prometheus-community.github.io/helm-charts
helm repo update
helm repo list

# Create namespcaes for service isolation.
kubectl create ns promethues-ns

# Install prometheus from repo
echo "**------------- Installing prometheus --------------**"
helm install prometheus prometheus-repo/prometheus -n prometheus-ns --set alertmanager.persistentVolume.storageClass="gp2" --set server.persistentVolume.storageClass="gp2"

# Follow below changes; if above command left 'promethus-server in pending state.
echo "-> here we used storageClass = Standard; if you want to use 'gp2' from AWS EBS volume upgrade standard to gp2 in above command.
      -> first check the PVC for 'promethus-server' and delete it if server creation is in Pending state.
      -> Then upgrade resoruce by command."
echo "CMD: helm install prometheus prometheus-repo/prometheus -n prometheus-ns --set alertmanager.persistentVolume.storageClass=standard --set server.persistentVolume.storageClass=standard"

echo "**--------------- Verify resources ------------**"
kubectl get all -n prometheus-ns

