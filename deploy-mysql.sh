#!/bin/bash
sudo apt-get update
#export DEBIAN_FRONTEND=noninteractive
if [ $# -ge 1 ]
then
    password=$1
else
    password="mysql!P@ss"
fi
#mysqladmin -u root password ${password}
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${password}"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${password}"

sudo apt-get install -y mysql-server
