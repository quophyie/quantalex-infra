#!/bin/sh

# This build/runs all containers i.e. microservices (i.e. quantal* services) and shared services such as (zookeeper and Kafka

source ././../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh

source ./shared_variables.sh

if [ -z "$DEPLOY_MS" ];then
    echo "DEPLOY_MS has not been set. Setting DEPLOY_MS to default value of true"
    DEPLOY_MS=true

else
    echo "DEPLOY_MS has been set. ${DEPLOY_MS}"
fi

#    $2 = BUILD_CONTAINER - a boolean (either true of false) that determines whether the services containers will be
#                           built before starting
BUILD_CONTAINER=

if [ -z "$2" ]; then
    BUILD_CONTAINER=false
else
    # Covert input to lower case and trim leading and trailing white spaces
    BUILD_CONTAINER=$(echo "$2" | tr '[:upper:]' '[:lower:] | xargs')
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
   eval ${COMMAND}
   echo "Waiting 10 seconds for kafka / zookeeper to start before running acceptance tests on Jenkins"
   sleep 10
else
   COMMAND="docker-compose -f ${DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml up -d"
   echo "Running on local $COMMAND"
   eval ${COMMAND}
fi

# Build and Run Microservices
if [ ${DEPLOY_MS} == 'true' ]; then
    ## now loop through the above array
    for MS_DOCKER_COMPOSE_DIR in "${QUANTAL_MS_DOCKER_COMPOSE_DIRS[@]}"
    do
       echo "IN $MS_DOCKER_COMPOSE_DIR"

       # Microservice Container name
       MS_NAME=$(echo ${MS_DOCKER_COMPOSE_DIR} | rev | cut -d'/' -f 1 | rev)
       MS_DOCKER_LOGS_DIR=${MS_DOCKER_COMPOSE_DIR}/docker/logs
       INFRA_DOCKER_LOGS_DIR=${DOCKER_COMPOSE_SCRIPTS_ROOT}/logs

       MS_DOCKER_LOGS_FILE=${MS_DOCKER_LOGS_DIR}/${MS_NAME}-logs.txt
       INFRA_DOCKER_LOGS_FILE=${INFRA_DOCKER_LOGS_DIR}/${MS_NAME}-logs.txt
       COMMAND="cd ${MS_DOCKER_COMPOSE_DIR}/scripts && ./build_run_docker_microservice_containers.sh ${BUILD_CONTAINER} -d | tee  ${INFRA_DOCKER_LOGS_FILE} ${MS_DOCKER_LOGS_FILE}"

       mkdir -p ${MS_DOCKER_LOGS_DIR}
       mkdir -p ${INFRA_DOCKER_LOGS_DIR}

       echo "Running ${MS_NAME} on local with command ${COMMAND}"
       eval ${COMMAND}

       # Bring the logs to the front
       LOGS_COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml logs -f | tee -a ${INFRA_DOCKER_LOGS_FILE} ${MS_DOCKER_LOGS_FILE} &"

       echo "executing logs command: ${LOGS_COMMAND}"
       eval ${LOGS_COMMAND}
       cd ${DOCKER_COMPOSE_SCRIPTS_ROOT}
    done
fi

##### THIS SHOULD ALWAYS BE THE LAST COMMAND #####
# BRING SHARED INFRA LOGS TO THE FOREGROUND
docker-compose -f ${DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml logs -f

