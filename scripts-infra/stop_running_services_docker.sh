#!/bin/sh
# This script will stop all containers and WILL NOT REMOVE images associated with the
# microservice containers i.e. quantal* containers

# Make sure that the scripts repository has been checked out from git
# i.e. from https://github.com/quophyie/scripts.git
source ./../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# CONFLUENT_PLATFORM_ALL_IN_ONE_DIR is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh

source shared_variables.sh

    ## now loop through the above array
    for MS_DOCKER_COMPOSE_DIR in "${QUANTAL_MS_DOCKER_COMPOSE_DIRS[@]}"
    do
       echo "IN $MS_DOCKER_COMPOSE_DIR"
       #COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/build_docker_container.sh"
       COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml stop"

       # Get the container ids
       CONTAINER_IDS=(`docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml ps -q`)
       CONTAINERS_TO_STOP=""
       for CONTAINER_ID in "${CONTAINER_IDS[@]}"
        do

            # Get the container name from container id
            CONTAINER_NAME=`docker ps --filter "id=${CONTAINER_ID}" --format "{{.Names}}"`
            CONTAINERS_TO_STOP=$(echo "${CONTAINERS_TO_STOP} ${CONTAINER_NAME},")

        done
        echo "Stopping container(s) named: ${CONTAINERS_TO_STOP}"

        COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml down"
        echo "\n Running command $COMMAND\n"
        eval ${COMMAND}


       eval "cd ${KONG_DOCKER_COMPOSE_SCRIPTS_ROOT}"
    done


# Stop shared non microservice containers
COMMAND="docker-compose -f ${KONG_DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml -f ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/docker-compose.yml stop"
echo "\nRunning command $COMMAND\n"
eval ${COMMAND}

