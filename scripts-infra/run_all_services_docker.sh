#!/bin/sh

# This build/runs all containers i.e. microservices (i.e. quantal* services) and shared services such as (zookeeper and Kafka

# Make sure that the scripts repository has been checked out from git
# i.e. from https://github.com/quophyie/scripts.git
source ./../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# KONG_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# CONFLUENT_PLATFORM_ALL_IN_ONE_DIR is defined in shared_variables.sh
# CONFLUENT_DOCKER_TAG is defined in shared_variables.sh
# REPOSITORY is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh

source shared_variables.sh

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


# run all the shared services. send it to the background
source ./run_shared_services_docker.sh $1 &

# Build and Run Microservices
if [ ${DEPLOY_MS} == 'true' ]; then
    ## now loop through the above array
    for MS_DOCKER_COMPOSE_DIR in "${QUANTAL_MS_DOCKER_COMPOSE_DIRS[@]}"
    do
       echo "IN $MS_DOCKER_COMPOSE_DIR"

       # Microservice Container name
       MS_NAME=$(echo ${MS_DOCKER_COMPOSE_DIR} | rev | cut -d'/' -f 1 | rev)
       MS_DOCKER_LOGS_DIR=${MS_DOCKER_COMPOSE_DIR}/docker/logs
       INFRA_DOCKER_LOGS_DIR=${KONG_DOCKER_COMPOSE_SCRIPTS_ROOT}/logs

       MS_DOCKER_LOGS_FILE=${MS_DOCKER_LOGS_DIR}/${MS_NAME}-logs.txt
       INFRA_DOCKER_LOGS_FILE=${INFRA_DOCKER_LOGS_DIR}/${MS_NAME}-logs.txt
       COMMAND="cd ${MS_DOCKER_COMPOSE_DIR}/scripts && ./build_run_docker_microservice_containers.sh ${BUILD_CONTAINER} -d | tee  ${INFRA_DOCKER_LOGS_FILE} ${MS_DOCKER_LOGS_FILE}"

       mkdir -p ${MS_DOCKER_LOGS_DIR}
       mkdir -p ${INFRA_DOCKER_LOGS_DIR}

       echo "Running ${MS_NAME} on local with command ${COMMAND}"
       eval ${COMMAND}

       # Bring the logs to the front
       LOGS_COMMAND="REPOSITORY=${REPOSITORY} CONFLUENT_DOCKER_TAG=${CONFLUENT_DOCKER_TAG} docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml logs -f | tee -a ${INFRA_DOCKER_LOGS_FILE} ${MS_DOCKER_LOGS_FILE} &"

       echo "executing logs command: ${LOGS_COMMAND}"
       eval ${LOGS_COMMAND}
       cd ${KONG_DOCKER_COMPOSE_SCRIPTS_ROOT}
    done
fi

##### THIS SHOULD ALWAYS BE THE LAST COMMAND #####
# BRING SHARED INFRA LOGS TO THE FOREGROUND
fg 1 && source ./show_shared_services_log.sh | tee -a ${INFRA_DOCKER_LOGS_DIR}/shared-services.log


