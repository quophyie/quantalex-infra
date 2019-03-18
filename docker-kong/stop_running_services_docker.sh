#!/bin/sh


DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/compose
QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../../

# *** NOTE ****
# DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh
source shared_variables.sh


    ## now loop through the above array
    for MS_DOCKER_COMPOSE_DIR in "${QUANTAL_MS_DOCKER_COMPOSE_DIRS[@]}"
    do
       echo "IN $MS_DOCKER_COMPOSE_DIR"
       #COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/build_docker_container.sh"
       COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml down"
       echo "\nRunning command $COMMAND \n"
       eval $COMMAND
       eval "cd ${DOCKER_COMPOSE_SCRIPTS_ROOT}"
    done


COMMAND="docker-compose -f ${DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml down"
echo "\nRunning command $COMMAND\n"
eval ${COMMAND}

