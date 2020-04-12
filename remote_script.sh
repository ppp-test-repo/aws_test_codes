#!/bin/bash

#cd /home/ec2-user;

username=$(whoami);
curr_dir=$(pwd);

cd /home/$username;
sudo yum install -y mysql httpd zip unzip java-1.8.0-openjdk-devel;
export JAVA_HOME="/usr/lib/jvm/jre";
export JAVA_OPTS="-Djava.security.egd=file:///dev/urandom";

echo -e "\n";
# read -p "Please enter MySQL RDS instance Endpoint :- " rds_endpoint;
# read -p "Please enter MySQL RDS instance DB_username :- " rds_user;
# read -p "Please enter MySQL RDS instance DB_password :- " rds_pass;
# echo -e "\n";

sudo chmod 777 remote_env;
source remote_env;

echo -e "\nSetting up tomcat\n";
sudo useradd tomcat;
sudo unzip tomcat.zip;
sudo chown -R tomcat:tomcat tomcat/
sudo mv tomcat/ /opt;

#echo -e "\nPlease enter rds password when promted";
echo -e "\nWating for 40 second before db process\n";
sleep 40;

echo -e "\nSetting up MySQL database\n";

mysql -h $rds_endpoint -P 3306 -u $rds_user -p$rds_pass < $curr_dir/Bookstore.sql;

echo -e "\nDeploying Application\n";
sudo mv Bookstore-Ant-build.war /opt/tomcat/webapps/;
sudo chown -R tomcat:tomcat /opt/tomcat/;


sudo mv tomcat.service /etc/systemd/system/tomcat.service;
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl status tomcat
sudo netstat -tulpan | grep 80

sudo cp /home/$username/dbdepweb.xml /opt/tomcat/webapps/Bookstore-Ant-build/WEB-INF/web.xml;
sudo chown -R tomcat:tomcat /opt/tomcat/;
sudo systemctl restart tomcat;



#echo -e "\nAs tomcat user please login to App tier server and run below command";
#echo -e "source remote_env;";
#echo -e "/opt/tomcat/bin/startup.sh;";


