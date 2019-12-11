#!/bin/bash

options=$(getopt -l "zep:" -o "z:" -a -- "$@")
eval set -- "$options"
echo "got:$options"
zepdep="org.apache.spark:spark-streaming-kafka-0-10_2.11:2.3.0,org.apache.spark:spark-sql-kafka-0-10_2.11:2.3.0"

while true
do
  case $1 in
    -z|--zep)
        shift
        export zep=$1
        ;;
    --)
        shift
        break;;
  esac
  shift
done
echo "parsed args..."
KAFKA_VER="2.3.0"
SCALA_VER="2.12"

DOWNLOADURL="https://www-eu.apache.org/dist/kafka/${KAFKA_VER}/kafka_${SCALA_VER}-${KAFKA_VER}.tgz"

echo "Downloading Apache Kafka ${KAFKA_VER}..."
sudo wget -q -O /opt/kafka.tgz ${DOWNLOADURL}
echo "Unpacking Kafka into /opt"
sudo tar -xzf /opt/kafka.tgz --directory /opt
echo "Making Kafka available in /opt/kafka"
sudo ln -s /opt/kafka_${SCALA_VER}-${KAFKA_VER} /opt/kafka

cd /opt/kafka
echo "Starting zookeeper..."
sudo ./bin/zookeeper-server-start.sh config/zookeeper.properties >> /tmp/zookeeper.log 2>&1 &
sleep 3
echo "Starting Kafka broker..."
sudo ./bin/kafka-server-start.sh config/server.properties >> /tmp/kafka.log 2>&1 &

if [ ! -z "$zep" ];
then
    #add kafka dependency to zeppelin
    #assumes zeppelin runs on this server as well
    echo "Adding dependencies for Zeppelin..."
    cfile="/tmp/interpreterk.json"
    sudo cp /opt/zeppelin/conf/interpreter.json ${cfile}
    
    set -f; IFS=','
    set -- $zepdep
    for dep in "$@"
    do
      echo "adding dependency: ${dep}..."
      trim=$(echo ${dep}|tr -dc '[:alnum:]')
      next="/tmp/${trim}.json"
      jq ".interpreterSettings.spark.dependencies += [{\"groupArtifactVersion\": \"${dep}\",\"local\": false}]" ${cfile} | sudo tee ${next} > /dev/null
      cfile=${next}
      sleep 1
    done
    set +f; unset IFS    
    sudo cp /tmp/interpreterk.json ${zep}/conf/interpreter.json
    echo "Restarting zeppelin..."
    sudo ${zep}/bin/zeppelin-daemon.sh restart
else
    echo "not touching zeppelin (${zep})"
fi 
echo "done."