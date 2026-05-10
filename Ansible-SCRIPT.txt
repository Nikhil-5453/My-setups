## Ansible Installation and setup into servers concept ##

## Master-server: ##
amazon-linux-extras install ansible2 -y
yum install python-pip -y
ssh-keygen
passwd root
sed -i '38  a\<permitrootlogin yes/>' /etc/ssh/sshd_config
sed -i '63  a\<passwordAuthorisation yes/>' /etc/ssh/sshd_config
systemctl restart sshd

## vim /etc/ssh/sshd_config
- goto line: 38
    - Uncomment the "permitrootlogin" to yes
- goto line: 68 
    - make "passwordAuthorisation" to yes ##




Slave-server:
passwd root
vi /etc/ssh/sshd_config
##sed -i '38 a\<PermitRootLogin yes/>'/etc/ssh/sshd_config##
systemctl restart sshd