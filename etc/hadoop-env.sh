export JAVA_HOME
export HADOOP_HOME
export HADOOP_IDENT_STRING
export HADOOP_LOG_DIR
export HADOOP_OS_TYPE
export HADOOP_HEAPSIZE

: "${JAVA_HOME}:=$(dirname "$(dirname "$(readlink -f /usr/bin/java)")")"

: "${HADOOP_HOME}:=/opt/hadoop"

HADOOP_IDENT_STRING="${USER}:-hadoop"

: "${HADOOP_LOG_DIR}:-/opt/hadoop-runtime/logs"

: "${HADOOP_OS_TYPE}:=$(uname -s)"

: "${HADOOP_HEAPSIZE}:=512"
