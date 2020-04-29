#!/bin/sh
# This script will stop all containers and WILL NOT REMOVE images associated with the
# microservice containers i.e. quantal* containers

# Make sure that the scripts repository has been checked out from git
# i.e. from https://github.com/quophyie/scripts.git
source ./../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# KONG_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# CONFLUENT_PLATFORM_ALL_IN_ONE_DIR is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh

source shared_variables.sh

# Stop shared non microservice containers
exec_shared_services_docker_compose_command stop