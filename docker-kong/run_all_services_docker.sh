#!/bin/sh

# This runs docker images (zookeeper and Kafka)

# DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../docker
#DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/compose
#QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../../
#declare -a QUANTAL_MS_DOCKER_COMPOSE_DIRS=("${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantalex-users"
#                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-auth"
#                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-telephones-service"
#                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-email-service"
#                )

# *** NOTE ****
# DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh
BUILD_CONTAINER=

if [ -z "$1" ]; then
    BUILD_CONTAINER=false
else
    # Covert input to lower case and trim leading and trailing white spaces
    BUILD_CONTAINER=$(echo "$1" | tr '[:upper:]' '[:lower:] | xargs')
fi

source ./shared_variables.sh

if [ -z "$DEPLOY_MS" ];then
    echo "DEPLOY_MS has not been set. Setting DEPLOY_MS to default value of true"
    DEPLOY_MS=true

else
    echo "DEPLOY_MS has been set. ${DEPLOY_MS}"
fi

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

if [ "${ON_JENKINS}" ]; then
   COMMAND="docker-compose -f ${DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml up -d"
   echo "Running on Jenkins $COMMAND"
   eval $COMMAND
   echo "Waiting 10 seconds for kafka / zookeeper to start before running acceptance tests on Jenkins"
   sleep 10
else
   COMMAND="docker-compose -f ${DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml up -d"
   echo "Running on local $COMMAND"
   eval $COMMAND
fi

# Build and Run Microservices
if [ ${DEPLOY_MS} == 'true' ]; then
    ## now loop through the above array
    for MS_DOCKER_COMPOSE_DIR in "${QUANTAL_MS_DOCKER_COMPOSE_DIRS[@]}"
    do
       echo "IN $MS_DOCKER_COMPOSE_DIR"
       #COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/build_docker_container.sh"
       COMMAND="cd ${MS_DOCKER_COMPOSE_DIR}/scripts && ./build_run_docker_container.sh ${BUILD_CONTAINER} -d"
       echo "Running on local $COMMAND"
       eval $COMMAND
       eval "cd ${DOCKER_COMPOSE_SCRIPTS_ROOT}"
    done
fi

##### THIS SHOULD ALWAYS BE THE LAST COMMAND #####
# BRING SHARED INFRA LOGS TO THE FOREGROUND

docker-compose -f ${DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml logs -f

