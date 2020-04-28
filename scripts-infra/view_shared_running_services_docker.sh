#!/bin/sh

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

   COMMAND="docker-compose -f ${KONG_DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml ps -f ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/docker-compose.yml ps"
   echo "\nRunning command $COMMAND\n"
   eval ${COMMAND}



