## Install aws-cli, kubectl, eksctl ##

echo "--------Installing awscli on server----------"
echo "Removing existing cli"
sudo yum remove awscli -y

echo "Installing latest version of aws-cli by curl"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "modifying permissions"
sudo chmod +x aws
rm -rf awscliv2.zip

echo "modify export in .bashrc"
sed -i '$ a\export PATH=$PATH:/usr/local/bin' ~/.bashrc
source ~/.bashrc


echo "---------Installing kubectl--------"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "Installing eksctl"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/

echo "===================Checking intallation===================="
echo "--------checking executable path---------"
echo $PATH

echo "-------------awscli version--------------"
which aws
aws --version

echo "-------------EKSCTL version----------------"
eksctl version
which eksctl

echo "------------Kubectl version-------------"
kubectl version --client

echo "**===============Installtions successfull=============**"


: << 'END'
# Create a EKS cliuster using eksctl
echo "------------- Creating EKS Cluster using eksctl -------------"
eksctl create cluster --name=EKS-1 --region=ap-south-1 --zones=ap-south-1a,ap-south-1b --without-nodegroup

# Attach a IAM ROLE to the eksctl role to allow it to create nodegroups
echo "------------- Attaching IAM ROLE to eksctl -------------"
eksctl utils associate-iam-oidc-provider --region ap-south-1 --cluster EKS-1 --approve

# Create a nodegroup using eksctl
echo "------------- Creating Nodegroup using eksctl -------------"
eksctl create nodegroup --cluster EKS-1 --region ap-south-1 --name=EKS-1-ng \
--node-type=c7i-flex.large --nodes=2 --nodes-min=1 --nodes-max=3 --node-volume-size=20 \
--ssh-access --ssh-public-key=<key_pair> --managed \
--asg-access --external-dns-access --full-ecr-access --appmesh-access --alb-ingress-access

END