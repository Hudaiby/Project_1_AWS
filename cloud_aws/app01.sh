#!/bin/bash
sudo apt update 
sudo apt upgrade -y
echo "app01" > hostname
sudo cp hostname /etc/hostname
sudo apt install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo useradd -m -d /usr/local/tomcat -U -s /bin/false tomcat

sudo apt install openjdk-11-jdk openjdk-11-jre -y
sudo apt install git maven wget -y

cd /tmp/
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.28/bin/apache-tomcat-10.1.28.tar.gz
tar xzvf apache-tomcat-10*.tar.gz -C /usr/local/tomcat
sudo chown -R tomcat:tomcat /usr/local/tomcat/
sudo chmod -R u+x /usr/local/tomcat/bin

## create srvice file ##
echo "[Unit]" >> /etc/systemd/system/tomcat.service
echo "Description=Tomcat" >> /etc/systemd/system/tomcat.service
echo "After=network.target" >> /etc/systemd/system/tomcat.service

echo "[Service]" >> /etc/systemd/system/tomcat.service
echo "Type=forking" >> /etc/systemd/system/tomcat.service

echo "User=tomcat" >> /etc/systemd/system/tomcat.service
echo "Group=tomcat" >> /etc/systemd/system/tomcat.service

echo "Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"" >> /etc/systemd/system/tomcat.service
echo "Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"" >> /etc/systemd/system/tomcat.service
echo "Environment="CATALINA_BASE=/usr/local/tomcat"" >> /etc/systemd/system/tomcat.service
echo "Environment="CATALINA_HOME=/usr/local/tomcat"" >> /etc/systemd/system/tomcat.service
echo "Environment="CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid"" >> /etc/systemd/system/tomcat.service
echo "Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"" >> /etc/systemd/system/tomcat.service

echo "ExecStart=/usr/local/tomcat/bin/startup.sh" >> /etc/systemd/system/tomcat.service
echo "ExecStop=/usr/local/tomcat/bin/shutdown.sh" >> /etc/systemd/system/tomcat.service

echo "RestartSec=10" >> /etc/systemd/system/tomcat.service
echo "Restart=always" >> /etc/systemd/system/tomcat.service

echo "[Install]" >> /etc/systemd/system/tomcat.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/tomcat.service
## end of tomcat service file ##

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
sed -i '5s/jdbc.password=admin123/jdbc.password=passme1/' src/main/resources/application.properties
sed -i '16s/rabbitmq.address=rmq01/rabbitmq.address=mq01/' src/main/resources/application.properties
sudo mvn install
sudo systemctl stop tomcat
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo systemctl start tomcat
sudo chown tomcat:tomcat /usr/local/tomcat/webapps -R
sudo systemctl restart tomcat

echo "Thes machines noiw prepaired to act as a web appalication based on tomcat java web server."
echo "Machine will reboot now ... brb"

sudo reboot