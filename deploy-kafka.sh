#!/bin/bash

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
echo "done."