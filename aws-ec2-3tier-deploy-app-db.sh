#!/bin/bash

cd /home/ec2-user;

initial_function () {

sudo yum install -y httpd zip unzip java-1.8.0-openjdk-devel git;

export JAVA_HOME="/usr/lib/jvm/jre" ;
export JAVA_OPTS="-Djava.security.egd=file:///dev/urandom";

echo -e "\n \t 1) Downlaod compiled source code \n\t 2) Downlaod and compile source ";

read -p "$(echo -e '\t') Choose your option 1 or 2 or hit enter for default 1 :- " optn;

  if [[ $optn == "" ]];
    then
      optn=1;
    fi	  

    if [[ $optn == 1 ]];
      then
        git clone https://github.com/ppp-test-repo/aws_test_codes.git;
        cd aws_test_codes;
        git checkout -b webapp-3tier-dep origin/webapp-3tier-dep;
        
        sudo rm -rf README.md .git;
        cd ..;
        sudo mkdir -p project_dep;
        sudo mv aws_test_codes/* project_dep/;
        sudo rm -rf aws_test_codes;
        sudo chmod -R 777 project_dep;
        ###sudo cp /home/ec2-user/*.pem project_dep;	
        cd project_dep;
        curr_dir=$(pwd);
		
        echo -e "\n";
        read -p "Please enter MySQL RDS instance Endpoint :- " rds_endpoint;
        read -p "Please enter MySQL RDS instance DB_username :- " rds_user;
        read -p "Please enter MySQL RDS instance DB_password :- " rds_pass;
        echo -e "\n";
        
        echo -e "rds_endpoint=$rds_endpoint\n" > remote_env;
        echo -e "rds_user=$rds_user\n" >> remote_env;
        echo -e "rds_pass=$rds_pass\n" >> remote_env;
        echo -e "JAVA_HOME=$JAVA_HOME" >> remote_env;
        echo -e "JAVA_OPTS=$JAVA_OPTS" >> remote_env;
        sudo chmod 777 remote_env;
        
        
        # sudo unzip -d Bookstore-Ant-build/ Bookstore-Ant-build.war;
        # sudo chown -R ec2-user:ec2-user Bookstore-Ant-build/;
        # sudo sed -i "s/root/$rds_user/" Bookstore-Ant-build/WEB-INF/web.xml;
        # sudo sed -i "s/localhost/$rds_endpoint/" Bookstore-Ant-build/WEB-INF/web.xml;  
        # sudo sed -i "s/pp@nasa123/$rds_pass/" Bookstore-Ant-build/WEB-INF/web.xml;
        # sudo zip -r Bookstore-Ant-build.war;
        
        unzip -d Bookstore-Ant-build/ Bookstore-Ant-build.war;
        chown -R ec2-user:ec2-user Bookstore-Ant-build/;
        sed -i "s/root/$rds_user/" Bookstore-Ant-build/WEB-INF/web.xml;
        sed -i "s/localhost/$rds_endpoint/" Bookstore-Ant-build/WEB-INF/web.xml;  
        sed -i "s/pp@nasa123/$rds_pass/" Bookstore-Ant-build/WEB-INF/web.xml;
        zip -r Bookstore-Ant-build.war Bookstore-Ant-build/;
        
        sudo mkdir -p sql; 
        sudo cp Bookstore.sql sql/;
        
     elif [[ $optn == 2 ]];
      then
        sudo yum install -y git ant;
        git clone https://github.com/ppp-test-repo/aws_test_codes.git;
        cd aws_test_codes;
        git checkout -b webapp-3tier origin/webapp-3tier;
        	
        sudo rm -rf README.md .git;
        sudo cd ..;
        sudo mkdir -p project_dep;
        sudo mv aws_test_codes/* project_dep/;
        sudo rm -rf aws_test_codes;
        sudo chmod -R 777 project_dep;
        ##sudo cp /home/ec2-user/*.pem project_dep;        
        cd project_dep;
        curr_dir=$(pwd);
        	
        	
        echo -e "\n";
        read -p "Please enter MySQL RDS instance Endpoint :- " rds_endpoint;
        read -p "Please enter MySQL RDS instance DB_username :- " rds_user;
        read -p "Please enter MySQL RDS instance DB_password :- " rds_pass;
        echo -e "\n";
        
        echo -e "rds_endpoint=$rds_endpoint\n" > remote_env;
        echo -e "rds_user=$rds_user\n" >> remote_env;
        echo -e "rds_pass=$rds_pass\n" >> remote_env;
        echo -e "JAVA_HOME=$JAVA_HOME" >> remote_env;
        echo -e "JAVA_OPTS=$JAVA_OPTS" >> remote_env;
        echo -e "CATALINA_BASE=/opt/tomcat" >> remote_env;
        echo -e "CATALINA_HOME=/opt/tomcat" >> remote_env;
        echo -e "JRE_HOME=$JAVA_HOME" >> remote_env;
		
        sudo chmod 777 remote_env;
        
#        sudo sed -i "s/root/$rds_user/" WebContent/WEB-INF/web.xml;
#        sudo sed -i "s/localhost/$rds_endpoint/" WebContent/WEB-INF/web.xml;  
#        sudo sed -i "s/pp@nasa123/$rds_pass/" WebContent/WEB-INF/web.xml;
        
        sed -i "s/root/$rds_user/" WebContent/WEB-INF/web.xml;
        sed -i "s/localhost/$rds_endpoint/" WebContent/WEB-INF/web.xml;  
        sed -i "s/pp@nasa123/$rds_pass/" WebContent/WEB-INF/web.xml;
		
        ant war;
        
     else
        echo -e "\n Please enter 1 or 2 or hit return/enter \n";
        exit 2;		
    fi
    
 echo -e "\n";
 
 cd /home/ec2-user/project_dep;
 curr_dir=$(pwd);	
}

task_one() {   
   echo -e "\n Please upload keypair file to $curr_dir \n";
   main;
   echo -e "\n";   
}
    
task_two() {
   cd /home/ec2-user/project_dep;
   curr_dir=$(pwd);
   #cd $curr_dir;
   #echo -e "\n Web url contect should be same as your war file name\n";
   #read -p "Please enter web url context example :- /test  :-  " web_url_context;
   
   web_url_context=$( ls | grep war | cut -d '.' -f 1);
   
   echo -e "\n";
   read -p "Please enter web url of App tier IP or  ELB DNS Name  :-  " app_elb_url;
   
   urlpath="http://${app_elb_url}:8080/${web_url_context}"
   
   
    echo -e "\n<VirtualHost *:*>\n\n" > tomcat.conf;
    echo -e "\tProxyPreserveHost On" >> tomcat.conf;
    echo -e "\tProxyPass /$web_url_context $urlpath/" >> tomcat.conf;
    echo -e "\tProxyPassReverse /$web_url_context $urlpath/" >> tomcat.conf;
    echo -e "\n</VirtualHost>\n\n" >> tomcat.conf;
    sudo cp -f $curr_dir/tomcat.conf /etc/httpd/conf.d/;
	sudo systemctl start httpd;
    echo -e "\n";
    
    read -p "Please enter key pair file name :- " keypair;
    sudo chmod 400 $curr_dir/$keypair;
    rs=$(echo $?);
    if [[ $rs == 0 ]];
        then 
           echo -e "\n";
           read -p "Please enter App tier server private IP Address:- " app_ip;
           read -p "Please enter App tier username default is ec2-user :- " username;
           if [[ $username == "" ]]; 
             then
               username=ec2-user;
           fi   
           echo -e "\n";
           
           scp -i $keypair Bookstore-Ant-build.war $username@$app_ip:/home/$username;
           scp -i $keypair $curr_dir/sql/Bookstore.sql $username@$app_ip:/home/$username;
           scp -i $keypair $curr_dir/tomcat.service $username@$app_ip:/home/$username;
		   scp -i $keypair $curr_dir/tomcat $username@$app_ip:/home/$username;
           scp -i $keypair tomcat.zip $username@$app_ip:/home/$username;
           scp -i $keypair remote_script.sh $username@$app_ip:/home/$username;
           scp -i $keypair remote_env $username@$app_ip:/home/$username;
           
           echo -e "\n Please run remote_script.sh on App tier server";
           
           #ssh -i $keypair $username@$app_ip;
           ssh -i $keypair $username@$app_ip 'bash remote_script.sh';
           #ssh -i $keypair $username@$app_ip 'bash -s' < remote_script.sh;
           #cat remote_script.sh | ssh -i $keypair $username@$app_ip;
           
      else 
           echo -e "\n Result failed due to keypair file not found at $curr_dir/$keypair \n";
           echo -e "Please upload file and re run this script";
           exit 2;
            
    fi
}

 region_name="";
 vpc_name="";
 sub_tag="";
 app_route_tag="";
 elip_aid="";
 nat_gw_id="";

aws_conf () {
   
   #echo -e "Please prepare with below detail handy with you.\n";
   #echo -e "AWS Region Name examp if your region is Mumabi than Region Name is ap-south-1\n ";
   #echo -e "\t AWS Access Key ID [None]: \n\t AWS Secret Access Key [None]: \n\t Default region name [None]:\n\t Default output format [None]: table \n";
   # 
   #aws configure;
   #
   echo -e "\n";
   read -p "Please enter AWS Region Name examp if your region is Mumabi than Region Name is ap-south-1 :- " region_name ;
   echo -e "\n";

}


create_nat () {
  
    read -p "Enter VPCName :- " vpc_name;
    echo -e "Below is you VPC full detail \n";
    aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" --region=$region_name --output=table;
    
    #echo -e "\nVpcId is as follow\n";
    #aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" --region=$region_name | grep "VpcId" | cut -d ":" -f 2 | cut -d "," -f 1;
    vpc_id_sub=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" --region=$region_name | grep "VpcId" | cut -d ":" -f 2 | cut -d "," -f 1;);
    
    echo -e "\nAllocating elastic ip for NAT gateway\n";
    aws ec2 allocate-address --domain vpc --region=$region_name;
    
    echo -e "\nYou have below elastic IP allocated\n";
    aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --region=$region_name --output=table;
    elip_aid=$(aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --region=$region_name | grep "AllocationId" | cut -d ":" -f 2 | cut -d "," -f 1 | cut -d '"' -f 2;);
    
    echo -e "\nYou have below subnet configured\n"
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id_sub" --region=$region_name --output=table;
    echo -e "\n";
    #read -p "Please enter public subnet Name (example PublicSubnet-Web):- " sub_tag;
    sub_tag=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id_sub" --region=$region_name |  grep "PublicSubnet-" | cut -d ":" -f 2 | cut -d "," -f 1;);
    
    echo -e "\nBelow are the given tagged subnet details\n";
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id_sub" --filters "Name=tag:Name,Values=$sub_tag" --region=$region_name --output=table;
    pub_sub_id=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id_sub" --filters "Name=tag:Name,Values=$sub_tag" --region=$region_name | grep  "SubnetId" | cut -d ":" -f 2 | cut -d "," -f 1 | cut -d '"' -f 2 ;);
    
    echo -e "\nCreating NAT gateway\n";
    aws ec2 create-nat-gateway --subnet-id $pub_sub_id --allocation-id $elip_aid --region=$region_name ;

}

create_nat_route () {

    app_sub_tag=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id_sub" --region=$region_name |  grep "AppPrivateSubnet-" | cut -d ":" -f 2 | cut -d "," -f 1;);
    app_sub_id=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id_sub" --filters "Name=tag:Name,Values=$app_sub_tag" --region=$region_name | grep "SubnetId" | cut -d ":" -f 2 | cut -d '"' -f 2;);
	
    echo -e "\nBelow are app tier route table configured\n Please use it to find App tier route table id\n";
    aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc_id_sub" --filters "Name=association.subnet-id,Values=$app_sub_id"   --region=ap-south-1 --output=table ;
            
    echo -e "\nPlease search for \n\n\t aws:cloudformation:logical-id|  apprt \n\nKey Value in above table\nyou can find a Name under that Key use its value for next line input\n";
    #aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc_id_sub" --filters "Name=association.subnet-id,Values=$app_sub_id"  --filters Name=tag:"aws:cloudformation:logical-id",Values=apprt --region=ap-south-1
    
    read -p "Please enter App tier route table tag value :- " app_route_tag;
    echo -e "\nYou have below route table configured for given tag Name\n"
    aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc_id_sub" --filters Name=tag:"aws:cloudformation:logical-id",Values=$app_route_tag --region=$region_name --output=table;
    
    app_rt_tbl_id=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc_id_sub" --filters "Name=association.subnet-id,Values=$app_sub_id"   --region=ap-south-1 | grep "RouteTableId" | awk '{if(NR==1) print $0}' | cut -d ":" -f 2 | cut -d '"' -f 2;);
    
    echo -e "\nBelow NAT Gateway is configured\n";
    aws ec2 describe-nat-gateways --filter "Name=state,Values=pending,available" --region=$region_name --output table ;
    
    echo -e "\nCreating NAT Route for App tier subnet traffic to Nat gateway\n";
    #nat_gw_id1=$(aws ec2 describe-nat-gateways --region=$region_name | grep "NatGatewayId" | cut -d ":" -f 2 | cut -d "," -f 1; );
    nat_gw_id1=$(aws ec2 describe-nat-gateways --filter "Name=state,Values=pending,available" --region=$region_name | grep "NatGatewayId" | cut -d ':' -f 2 | cut -d '"' -f 2;)
    
    aws ec2 create-route --route-table-id $app_rt_tbl_id --destination-cidr-block 0.0.0.0/0 --gateway-id $nat_gw_id1 --region=$region_name ;


}

delete_nat () {
    
    
    nat_gw_id=$(aws ec2 describe-nat-gateways --filter "Name=state,Values=pending,available" --region=$region_name | grep "NatGatewayId" | cut -d ':' -f 2 | cut -d '"' -f 2;)
    aws ec2 delete-nat-gateway --nat-gateway-id $nat_gw_id --region=$region_name ;
	
    echo -e "Waiting for 2.5 minute to complete deletion of Nat Gateway";
    sleep 150;
    aws ec2 release-address --allocation-id $elip_aid  --region=$region_name;
    echo -e "Elastic IP is not released yet, Please relase it manually";
}

main() {

    echo -e "Please create IAM user and create access key of that user, download the CSV file of accesskey\n";
    echo -e "Save the downloaded accessKeys.csv as it requires to configure aws cli in next step\n";

    read -p "Did you created ec2-user IAM user and downloaded creadentialaccessKeys.csv for that user? (Y/y) :- " acc_ans;

    if [[ $acc_ans == "Y" || $acc_ans == "y" ]];
      then
        aws_conf;
        create_nat;
    	create_nat_route;
     else
        echo -e "It is mandatory to create IAM ec2-user, attached AmazonEC2FullAccess,AdministratorAccess and AmazonVPCFullAccess policies,\n Also  download its creadential/accessKeys.csv file and run this script again";
        exit 0; 
    fi

    read -p "Did you uploaded keypair file:- (Yy/Nn)" kp_ans;
    if [[ $kp_ans == "Y" || $kp_ans == "y" ]]; 
      then
       task_two;
       #delete_nat;
     else
       task_one;
	  
    fi
    
 }

 sudo setenforce Permissive;
 ##sudo sed -i 's/Enforcing/Permissive/g' /etc/sysconfig/selinux;
 ##sudo sed -i 's/Enforcing/Permissive/g' /etc/selinux/config /etc/selinux/config;
 #sudo sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=Permissive/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux;
 yum list telnet;
 echo -e "\n";
 read -p "Are you able see to yum result for telnet package? (Y/y) :- " int_res;
 if [[ $int_res == "Y" || $int_res == "y" ]];
   then
     initial_function;
     main;    
  else
    echo -e "Your web server is unable to send traffic to internet\n";
    echo -e "Please check your web-public-sg Security group for Outbond Rule destine to 0.0.0.0/0\n";
    echo -e "After that check with running command # yum list telnet and if result is success re-run this script\n";
    exit 0;
 fi   


