#!/bin/bash
#script that installs zeppelin with all dependencies and starts it
ZEP_VER="0.8.2"

options=$(getopt -l "setpass:,cassandra:" -o "s:c:" -a -- "$@")
eval set -- "$options"


while true
do
  case $1 in
    -s|--setpass)
        shift
        export password=$1
        ;;
    -c|--cassandra)
        shift
        export cassandra=$1
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

echo "getting Zeppeling Archive"
wget -q O /opt/zeppelin.tgz http://apache.javapipe.com/zeppelin/zeppelin-${ZEP_VER}/zeppelin-${ZEP_VER}-bin-all.tgz
echo "unpacking..."
tar -xzvf /opt/zeppelin.tgz
#enable authentication
cp /opt/zeppelin/conf/shiro.ini.template /opt/zeppelin/conf/shiro.ini
#the Apache shiro template comes with a bunch of users pre-defined, remove them
sed -i "/^user/d" /opt/zeppelin/conf/shiro.ini 
# admin default password in shiro.ini is password1, change it to a value of our own
sed -i "s/password1/${PASSWORD}/g" /opt/zeppelin/conf/shiro.ini

cp /opt/zeppelin/conf/zeppelin-site.xml.template /opt/zeppelin/conf/zeppelin-site.xml
#disable anonymous access
sed -i '/zeppelin.anonymous.allowed/{n;s/.*/<value>false<\/value>/}' /opt/zeppelin/conf/zeppelin-site.xml

echo "starting daemon..."
/opt/zeppelin/bin/zeppelin-daemon.sh start


if [ ! -z "$cassandra" ]
then
	echo "waiting for Zeppelin to start to set Cassandra host and dependencies..."
	#wait untin Zeppelin starts and creates the interpreter.json file
	sleep 45
	sed -i "s/\"cassandra.hosts\": \"localhost\"/\"cassandra.hosts\": \"${cassandra}\"/g" /opt/zeppelin/conf/interpreter.json
	sed -i "s/\"cassandra.cluster\": \"Test Cluster\"/\"cassandra.cluster\": \"CassandraTraining\"/g" /opt/zeppelin/conf/interpreter.json
	sed -i "s/\"spark.cores.max\": \"\"/\"spark.cores.max\": \"\",\"spark.cassandra.connection.host\": \"${cassandra}}\"/g" /opt/zeppelin/conf/interpreter.json
	echo "re-starting daemon..."
	/opt/zeppelin/bin/zeppelin-daemon.sh restart

fi

#enable automatic start at boot
sudo echo "/opt/zeppelin/bin/zeppelin-daemon.sh start" >> /etc/rc.local