#!/bin/bash
echo "Installing Java (OpenJDK flavor)..."
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

SPARK_VER="2.3.4"
HADOOP_VER="2.7"

DOWNLOADURL="https://archive.apache.org/dist/spark/spark-${SPARK_VER}/spark-${SPARK_VER}-bin-hadoop${HADOOP_VER}.tgz"
echo "Downloading Apache Spark ${SPARK_VER}..."
sudo wget -q -O /opt/spark.tgz ${DOWNLOADURL}
echo "Unpacking Spark into /opt"
sudo tar -xzf /opt/spark.tgz --directory /opt
echo "Making Spark available in /opt/spark"
sudo ln -s /opt/spark-${SPARK_VER}-bin-hadoop${HADOOP_VER} /opt/spark
echo "Starting Spark Master ..."
sudo /opt/spark/sbin/start-master.sh 

MEM=$(grep MemTotal /proc/meminfo | awk '{print int($2 * 0.66 / 1024) }')
CORES=$(grep -Pc '^processor\t' /proc/cpuinfo)

echo "Starting a Worker with ${MEM} MB (66% of total memory) and ${CORES} cores"

sudo /opt/spark/sbin/start-slave.sh -c ${CORES} -m ${MEM}M


