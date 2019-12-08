#!/bin/bash
sudo apt-get update
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y mysql-server
if [ $# -ge 1 ]
then
    password=$1
else
    password="mysql!P@ss"
fi
mysqladmin -u root password ${password}