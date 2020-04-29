#!/bin/sh


DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/compose
QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../../

# Make sure that the scripts repository has been checked out from git
# i.e. from https://github.com/quophyie/scripts.git
source ./../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# KONG_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# CONFLUENT_PLATFORM_ALL_IN_ONE_DIR is defined in shared_variables.sh
# INFRA_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh
source shared_variables.sh

# view running shared services
source ./view_shared_running_services_docker.sh
    ## now loop through the above array
    for MS_DOCKER_COMPOSE_DIR in "${QUANTAL_MS_DOCKER_COMPOSE_DIRS[@]}"
    do
       echo "IN $MS_DOCKER_COMPOSE_DIR"
       #COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/build_docker_container.sh"
       COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml ps"
       echo "\nRunning command $COMMAND \n"
       eval $COMMAND
       eval "cd ${INFRA_SCRIPTS_ROOT}"
    done




