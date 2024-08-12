#!/bin/bash
sudo apt update 
sudo apt upgrade -y
echo "db01" > hostname
sudo cp hostname /etc/hostname
sudo apt install git mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
printf "\n n\n y\n passme1\n passme1\n y\n n\n y\n y\n" | sudo mysql_secure_installation
echo "create database accounts;" | mysql -u root -ppassme1
echo "grant all privileges on accounts.* TO 'admin'@'%' identified by 'passme1';" | mysql -u root -ppassme1
echo "FLUSH PRIVILEGES;" | mysql -u root -ppassme1
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
sudo mysql -u root -ppassme1 accounts < src/main/resources/db_backup.sql
sudo systemctl restart mariadb
sudo apt install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
sudo reboot