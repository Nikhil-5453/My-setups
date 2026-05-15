cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
unzip sonarqube-8.9.6.50800.zip
amazon-linux-extras install java-openjdk11 -y
useradd sonar
chown -R sonar:sonar sonarqube-8.9.6.50800
su - sonar
cd /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/
sh sonar.sh start
sh sonar.sh status
cd
update-alternatives --config java

/*
------------------
port: 9000(Default)
login: default id and psswd is 'admin'
plugin: SonarQube scanner


setup:
=> Goto manage jenkins -> system -> find sonar in system setup
     -> add credentials for sonar and take sonar Token(myaccount -> security -> generate token) as "secret text" in creds.

-----------------

sample pipeline:

node{
    stage("code"){
        git 'https://github.com/Nikhil-5453/D-project.git'
    }
}
node{
    stage("Build"){
        sh 'mvn clean package'
    }
}
node{
    stage("CQA"){
        withSonarQubeEnv('<sonar-name>'){
            def mavenHome = tool name: "maven", type: "maven"
            def mavenCMD = "${mavenHome}/bin/mvn"
            sh "${mavenCMD} sonar:sonar"
        }
    }
*/