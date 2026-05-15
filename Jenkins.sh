

#!/bin/bash
# Jenkins installation script for Amazon Linux 2 with Amazon Corretto 21 (Java 21)

set -e

echo "Updating system..."
sudo yum update -y

echo "Installing Amazon Corretto 21 (Java 21)..."
sudo yum install -y java-21-amazon-corretto

echo "Installing Maven & git"
##sudo yum install maven -y
yum install git -y

echo "Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "Installing Jenkins..."
sudo yum install -y jenkins

echo "Configuring Jenkins to use Java 21..."
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
sudo tee -a /etc/sysconfig/jenkins <<EOF
JAVA_HOME=$JAVA_HOME_PATH
JENKINS_JAVA_CMD=$JAVA_HOME_PATH/bin/java
EOF

echo "Reloading systemd and starting Jenkins..."
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo "Opening firewall for Jenkins (port 8080)..."
sudo firewall-cmd --permanent --add-port=8080/tcp || true
sudo firewall-cmd --reload || true

echo "Checking Jenkins status..."
sudo systemctl status jenkins --no-pager

echo "Checking installation..."
java -version
mvn -v
git -v

echo "Jenkins installation completed. Access it at http://<your-server-public-ip>:8080"


#-----------------------------------------

# port: 8080(Default)

#-----------------------------------------

## First install maven and its java versions, if server need it in future. To avoid version mismatch for maven.

#yum install java-1.8.0-openjdk maven -y
#yum install git -y
#yum install java-17-amazon-corretto -y
#sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#yum install jenkins -y
#systemctl start jenkins
#systemctl status jenkins
#mvn -v

#--------------------------------------

# To change java version in server
# cmd: update-alternatives --config java
# => select appropriate version by giving index of java version