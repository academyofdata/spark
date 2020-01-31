#!/bin/bash

options=$(getopt -l "java,master,slaveof:" -o "jms:" -a -- "$@")
eval set -- "$options"

while true
do
  case $1 in
    -j|--java)
        export java=yes
        ;;
    -m|--master)
        export master=yes
        ;;
    -s|--slaveof)
        shift
        export masterurl=$1
        ;;
    --)
        shift
        break;;
  esac
  shift
done

if [ "$java" = "yes" ]; then
  echo "Installing Java (OpenJDK flavor)..."
  sudo apt-get update
  sudo apt-get install -y openjdk-8-jdk
fi

SPARK_VER="2.3.4"
HADOOP_VER="2.7"

DOWNLOADURL="https://archive.apache.org/dist/spark/spark-${SPARK_VER}/spark-${SPARK_VER}-bin-hadoop${HADOOP_VER}.tgz"
echo "Downloading Apache Spark ${SPARK_VER}..."
sudo wget -q -O /opt/spark.tgz ${DOWNLOADURL}
echo "Unpacking Spark into /opt"
sudo tar -xzf /opt/spark.tgz --directory /opt
echo "Making Spark available in /opt/spark"
sudo ln -s /opt/spark-${SPARK_VER}-bin-hadoop${HADOOP_VER} /opt/spark

MEMFACTOR=0.8

if [ "$master" = "yes" ]; then
  echo "Starting Spark Master ..."
  sudo /opt/spark/sbin/start-master.sh
  #point the slave to this master
  masterurl=$(hostname --ip-address)
  masterurl="spark://${masterurl}:7077"
  sudo echo "SPARK_MASTER_OPTS=\"-Dspark.deploy.defaultCores=1\"" >> /opt/spark/conf/spark-env.sh
  MEMFACTOR=0.66
fi

if [ ! -z "$masterurl" ];
then
  MEM=$(grep MemTotal /proc/meminfo | awk -v mem="${MEMFACTOR}" '{print int($2 * mem / 1024) }')
  CORES=$(grep -Pc '^processor\t' /proc/cpuinfo)
  echo "Starting a Worker with ${MEM} MB (${MEMFACTOR} of total memory), ${CORES} cores and master ${masterurl}"
  sudo /opt/spark/sbin/start-slave.sh -c ${CORES} -m ${MEM}M ${masterurl}
  #executor settings valid for e.g. spark-shell on this machine
  sudo echo "spark master ${masterurl}" >> /opt/spark/conf/spark-defaults.conf
  sudo echo "spark.executor.memory 1G" >> /opt/spark/conf/spark-defaults.conf
  sudo echo "spark.executor.cores 1" >> /opt/spark/conf/spark-defaults.conf
 
fi




