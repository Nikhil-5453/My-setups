## Minikube Installation script: ##

## Minikube requires a container runtime. Docker is the standard choice ##

echo "***** Install and setup docker runtime *****"
yum install docker -y && systemctl start docker

## Minikube can be installed by either binaries (or) rpm package ##

echo "***** Download Minikube binaries *****"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

echo "***** Installing binary *****"
sudo install minikube-linux-amd64 /usr/local/bin/minikube

echo "***** verifying installation *****"
minikube version


## kubectl is the CLI tool used to interact with your Kubernetes cluster. ##

echo "***** Installing kubectl CLI *****"
echo "***** kubectl Downloading.... *****"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "***** modifying kubectl permission *****"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/


echo "***** starting minikube *****"
minikube start --driver=docker --force
minikube status