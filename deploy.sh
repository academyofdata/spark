#!/bin/bash
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

SPARK_VER="2.3.4"
HADOOP_VER="2.7"

DOWNLOADURL="https://archive.apache.org/dist/spark/spark-${SPARK_VER}/spark-${SPARK_VER}-bin-hadoop${HADOOP_VER}.tgz"
echo "Downloading Apache Spark ${SPARK_VER}..."
sudo wget -q -O /opt/spark.tgz ${DOWNLOADURL}
echo "Unpacking Spark into /opt/spark"
sudo tar -xzf /opt/spark.tgz --directory /opt
echo "Making Spark available in /opt/spark"
sudo ln -s /opt/spark-${SPARK_VER}-bin-hadoop${HADOOP_VER} /opt/spark
echo "Starting Spark Master ..."
sudo /opt/spark/sbin/start-master.sh 


