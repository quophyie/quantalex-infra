#!/bin/sh

# This runs docker images for shared services such as (zookeeper and Kafka)

source ../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# KONG_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# CONFLUENT_PLATFORM_ALL_IN_ONE_DIR is defined in shared_variables.sh
# REPOSITORY is defined in shared_variables.sh
# CONFLUENT_DOCKER_TAG is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh

source shared_variables.sh

if [ "${ON_JENKINS}" ]; then
   export PATH=$PATH:$1/bin
   export HOST_IP=`/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1`
else
   export HOST_IP=`ifconfig en0 | grep inet | grep -v inet6 | cut -d' ' -f2`
fi

if [ "${HOST_IP}" ]; then
   echo "HOST_IP: $HOST_IP"
else
   echo "HOST_IP has not been defined."
   echo "Source the appropriate prepare script before running this script, or set HOST_IP to a valid IP address manually."
   exit 1;
fi

# Remove any shutdown kafka docker containers because they may have the wrong IP address and this will stop the
# Kafka producer scripts from working correctly after leaving the network and rejoining again later.
EXISTING_KAFKA_DOCKER_CONATINER_ID=`docker ps -a | grep kafka |  awk '{print $1}'`
if [ "$EXISTING_KAFKA_DOCKER_CONATINER_ID" ]; then
   echo "Removing previous Kafka docker container with id ${EXISTING_KAFKA_DOCKER_CONATINER_ID}"
   docker rm -f ${EXISTING_KAFKA_DOCKER_CONATINER_ID}
fi

EXISTING_ZOOKEEPER_DOCKER_CONATINER_ID=`docker ps -a | grep zook |  awk '{print $1}'`
if [ "$EXISTING_ZOOKEEPER_DOCKER_CONATINER_ID" ]; then
   echo "Removing previous zookeeper docker container with id ${EXISTING_ZOOKEEPER_DOCKER_CONATINER_ID}"
   docker rm -f ${EXISTING_ZOOKEEPER_DOCKER_CONATINER_ID}
fi

# Command to start shared services
COMMAND="REPOSITORY=${REPOSITORY} CONFLUENT_DOCKER_TAG=${CONFLUENT_DOCKER_TAG} exec_shared_services_docker_compose_command up -d"

if [ "${ON_JENKINS}" ]; then

    eval ${COMMAND}
   echo "Waiting 10 seconds for kafka / zookeeper to start before running acceptance tests on Jenkins"
   sleep 10
else
   eval ${COMMAND}
   source ./show_shared_services_log.sh | tee -a ${INFRA_SCRIPTS_ROOT}/shared-services.log
fi


