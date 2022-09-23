#!/bin/bash


yum update -y
mkdir -p /var/www/html/
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-04902cdce2e2dd4a7.efs.us-east-1.amazonaws.com:/ /var/www/html/
echo "fs-04902cdce2e2dd4a7.efs.us-east-1.amazonaws.com:/ /var/www/html/ efs defaults,_netdev 0 0"  >> /etc/fstab
yum install -y amazon-efs-utils
yum install -y httpd
systemctl start httpd
systemctl enable httpd
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cd /var/www/html/
rm -rf index.html
sudo systemctl restart httpd
echo "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXX" >> /home/ec2-user/.ssh/authorized_keys
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=60cfb769eb93ff2bfa298d9eabfb41ba DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
#################### If first is not word then you have to use this second command. which is commented.###############################
#DD_AGENT_MAJOR_VERSION=7 DD_UPGRADE=true DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
aws s3 cp s3://wordpress-document/datadog.yaml /etc/datadog-agent/datadog.yaml
systemctl start datadog-agent
systemctl enable datadog-agent
cd /var/log/ ; chmod 655 -R httpd
aws s3 cp s3://wordpress-document/datadog.yaml /etc/datadog-agent/
aws s3 cp s3://wordpress-document/httpd.conf /etc/httpd/conf/
aws s3 cp s3://wordpress-document/conf.yaml /etc/datadog-agent/conf.d/apache.d/
sudo systemctl restart httpd
systemctl restart datadog-agent
