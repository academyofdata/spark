#!/bin/bash
#script that installs zeppelin with all dependencies and starts it
ZEP_VER="0.8.2"

options=$(getopt -l "setpass:,cassandra:,port:,master:,dependencies:nodownload" -o "s:c:p:m:d:n" -a -- "$@")
eval set -- "$options"

export port=9090
export download=yes
while true
do
  case $1 in
    -s|--setpass)
        shift
        export password=$1
        ;;
    -n|--nodownload)
        export download=no
        ;;
    -p|--port)
        shift
        export port=$1
        ;;
    -c|--cassandra)
        shift
        export cassandra=$1
        ;;
    -m|--master)
        shift
        export master=$1
        ;;
    -d|--dependencies)
        shift
        export dependencies=$1
        ;;
    --)
        shift
        break;;
  esac
  shift
done

if [ ! -z "$password" ]
then
	PASSWORD=$password
else
	PASSWORD='zeplnp@ss'
fi

if [ "$download" = "yes" ]
then
  echo "getting Zeppelin Archive"
  sudo wget -q -O /opt/zeppelin.tgz http://apache.javapipe.com/zeppelin/zeppelin-${ZEP_VER}/zeppelin-${ZEP_VER}-bin-all.tgz
  echo "Unpacking Zeppelin into /opt"
  sudo tar -xzf /opt/zeppelin.tgz --directory /opt
  echo "Making Zeppelin available in /opt/zeppelin"
  sudo ln -s /opt/zeppelin-${ZEP_VER}-bin-all /opt/zeppelin
fi
#enable authentication
sudo cp /opt/zeppelin/conf/shiro.ini.template /opt/zeppelin/conf/shiro.ini
#the Apache shiro template comes with a bunch of users pre-defined, remove them
sudo sed -i "/^user/d" /opt/zeppelin/conf/shiro.ini 
# admin default password in shiro.ini is password1, change it to a value of our own
sudo sed -i "s/password1/${PASSWORD}/g" /opt/zeppelin/conf/shiro.ini
# remove the comment in the front of admin user so we enable login with 'admin'
lineno=$(grep -n "${PASSWORD}" /opt/zeppelin/conf/shiro.ini | awk -F: '{print $1}')
sudo sed -i "${lineno}s/^#//" /opt/zeppelin/conf/shiro.ini

sudo cp /opt/zeppelin/conf/zeppelin-site.xml.template /opt/zeppelin/conf/zeppelin-site.xml
#disable anonymous access
sudo sed -i '/zeppelin.anonymous.allowed/{n;s/.*/<value>false<\/value>/}' /opt/zeppelin/conf/zeppelin-site.xml
#change port
sudo sed -i "/zeppelin.server.port/{n;s/.*/<value>${port}<\/value>/}" /opt/zeppelin/conf/zeppelin-site.xml
#make the server avail on the internal interface, not on localhost
iface=$(hostname --ip-address)
sudo sed -i "/zeppelin.server.addr/{n;s/.*/<value>${iface}<\/value>/}" /opt/zeppelin/conf/zeppelin-site.xml

echo "starting daemon..."
sudo /opt/zeppelin/bin/zeppelin-daemon.sh start

restart="no"
sudo apt-get update
sudo apt-get install -y jq

if [ ! -z "$cassandra" ]
then
    echo "waiting for Zeppelin to start to set Cassandra host (${cassandra}) and dependencies..."
    #wait untin Zeppelin starts and creates the interpreter.json file
    sleep 30
    jq ".interpreterSettings.cassandra.properties[\"cassandra.hosts\"].value = \"${cassandra}\"" /opt/zeppelin/conf/interpreter.json | 
    jq ".interpreterSettings.cassandra.properties[\"cassandra.cluster\"].value = \"CassandraTraining\"" |
    jq ".interpreterSettings.spark.properties[\"spark.cassandra.connection.host\"].value= \"${cassandra}\"" | sudo tee /tmp/interpreter.json
    sudo mv /tmp/interpreter.json /opt/zeppelin/conf/interpreter.json
    restart="yes"
fi
if [ ! -z "$master" ]
then
    echo "Setting spark master..."
    jq ".interpreterSettings.spark.properties.master.value = \"${master}\"" /opt/zeppelin/conf/interpreter.json | sudo tee /tmp/interpreter.json
    sudo mv /tmp/interpreter.json /opt/zeppelin/conf/interpreter.json
    
    #we rely on the fact that a spark instalation already exists in /opt/spark
    echo "export SPARK_HOME=/opt/spark" | sudo tee /opt/zeppelin/conf/zeppelin-env.sh
    restart="yes"
fi
if [ ! -z "$dependencies" ]
then
    sudo cp /opt/zeppelin/conf/interpreter.json /tmp/interpreter.json
    set -f; IFS=','
    set -- $dependencies
    for dep in "$@"
    do
      jq ".interpreterSettings.spark.dependencies += [{\"groupArtifactVersion\": \"${dep}\",\"local\": false}]" /tmp/interpreter.json | sudo tee /tmp/interpreter.json
    done
    set +f; unset IFS
    sudo mv /tmp/interpreter.json /opt/zeppelin/conf/interpreter.json
    
    restart="yes"
fi

if [ "$restart" = "yes" ]; then
    sudo echo "re-starting daemon..."
    sudo /opt/zeppelin/bin/zeppelin-daemon.sh restart
fi
#enable automatic start at boot
sudo sed -i "$ i/opt/zeppelin-${ZEP_VER}-bin-all/bin/zeppelin-daemon.sh start" /etc/rc.local
