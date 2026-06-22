## Installing and setup of Kops ##
## Install aws-cli, kops, kubectl ##

echo "--------Installing awscli on server----------"
echo "Removing existing cli"
sudo yum remove awscli -y

echo "Installing latest version of aws-cli by curl"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "modifying permissions"
sudo chmod +x aws

echo "modify export in .bashrc"
sed -i '$ a\export PATH=$PATH:/usr/local/bin' ~/.bashrc
source ~/.bashrc

echo "--------Installing KOPS---------"
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops
sudo mv kops /usr/local/bin/kops

echo "---------Installing kubectl--------"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "===================Checking intallation===================="
echo "--------checking executable path---------"
echo $PATH

echo "-------------awscli version--------------"
which aws
aws --version

echo "-------------KOPS version----------------"
kops version

echo "------------Kubectl version-------------"
kubectl version --client

echo "**===============Installtions successful=============**"
