#!/bin/bash

echo '---------------------------------------------HDFS---------------------------------------------'

echo '---------------------------------------FORMAT NAMENODE---------------------------------------'
hdfs namenode -format -force -nonInteractive -clusterID hpdc

echo '----------------------------------------START NAMENODE----------------------------------------'
hadoop-daemon.sh start namenode
echo '-----------------------------------START SECONDARY NAMENODE-----------------------------------'
hadoop-daemon.sh start secondarynamenode
echo '----------------------------------------START DATANODE----------------------------------------'
hadoop-daemon.sh start datanode

echo '-----------------------------------CREATE HDFS DIRECTORIES-----------------------------------'
hdfs dfs -mkdir -p /apps /tmp /hive/warehouse /user/hadoop /user/dr.who
hdfs dfs -chmod -R 1777 /tmp
hdfs dfs -chmod 755 /apps

echo '---------------------------------------------HIVE---------------------------------------------'

echo '------------------------------------FORMAT HIVE METASTORE------------------------------------'
PGPASSWORD="${POSTGRES_PASSWORD}" psql --username postgres --host postgres -v ON_ERROR_STOP=1 <<-END
  DROP DATABASE IF EXISTS hive;
  CREATE DATABASE hive;
  GRANT ALL PRIVILEGES ON DATABASE hive TO postgres;;
END

echo '--------------------HIVE METASTORE POSTGRES_PASSWORD CRUTCH FOR HADOOP < 3--------------------'
sed -E -i "s/--POSTGRES_PASSWORD--/${POSTGRES_PASSWORD}/g" hive/conf/hive-site.xml

echo '-------------------------------------INIT HIVE METASTORE-------------------------------------'
schematool -initSchema -dbType postgres

echo '--------------------------------------START HIVE SERVER--------------------------------------'
hive --service hiveserver2 --skiphbasecp &

if [ $# -eq 0 ]; then
  tail -f /opt/hadoop-runtime/logs/*
else
  exec "$@"
fi
