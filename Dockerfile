FROM centos:centos8.3.2011

ARG HADOOP_VERSION
ARG HIVE_VERSION

RUN \
    echo '------------------------------------INSTALL DEPENDENCIES------------------------------------' \
    && yum update -y \
    && yum install -y wget \
    && echo '-------------------------------------DOWNLOAD HADOOP-------------------------------------' \
    && wget -q "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    && wget -q "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
    && echo '--------------------------------------INSTALL HADOOP--------------------------------------' \
    && tar -xaf "hadoop-${HADOOP_VERSION}.tar.gz" \
    && tar -xaf "apache-hive-${HIVE_VERSION}-bin.tar.gz" \
    && mv "hadoop-${HADOOP_VERSION}" /opt/hadoop \
    && mv "apache-hive-${HIVE_VERSION}-bin" /opt/hive \
    && echo '-----------------------------------------CLEANUP-----------------------------------------' \
    && rm --force "hadoop-${HADOOP_VERSION}.tar.gz" "apache-hive-${HIVE_VERSION}-bin.tar.gz" \
    && yum remove -y wget && yum clean all && rm -rf /tmp/* /var/tmp/*

RUN \
    echo '---------------------------------INSTALL DEPENDENCIES---------------------------------' \
    && yum update -y \
    && yum install -y \
        java-1.8.0-openjdk \
        postgresql \
    && echo '----------------------------------CREATE HADOOP USER----------------------------------' \
    && useradd --system --create-home --user-group --shell /bin/bash hadoop \
    && echo '----------------------------------HADOOP POST-INSTALL----------------------------------' \
    && rm /opt/hive/lib/log4j-slf4j* \
    && mkdir -p /opt/hadoop-runtime/logs \
    && chown hadoop:hadoop -R /opt \
    && echo '----------------------------------------CLEANUP----------------------------------------' \
    && yum clean all && rm -rf /tmp/* /var/tmp/*

USER hadoop

WORKDIR /opt

COPY --chown=hadoop:hadoop entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    HADOOP_LOG_DIR=/opt/hadoop-runtime/logs \
    HIVE_HOME=/opt/hive \
    HIVE_CONF_DIR=/opt/hive/conf \
    SPARK_CONF_DIR=/opt/spark/conf \
    PATH="${PATH}:/opt/hadoop/bin:/opt/hadoop/sbin:/opt/hive/bin"

COPY --chown=hadoop:hadoop \
    etc/hadoop-env.sh \
    etc/log4j.properties \
    etc/core-site.xml \
    etc/hdfs-site.xml \
    etc/mapred-site.xml \
    ${HADOOP_CONF_DIR}/

COPY --chown=hadoop:hadoop \
    etc/hive-env.sh \
    etc/hive-site.xml \
    ${HIVE_CONF_DIR}/

COPY --chown=hadoop:hadoop \
    etc/spark-defaults.conf \
    etc/spark-env.sh \
    etc/spark-log4j.properties \
    ${SPARK_CONF_DIR}/

RUN \
    chmod 755 /entrypoint.sh \
    && mv ${SPARK_CONF_DIR}/{spark-,}log4j.properties
