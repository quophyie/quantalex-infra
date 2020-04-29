#!/usr/bin/env bash

# Make sure that the scripts repository has been checked out from git
# i.e. from https://github.com/quophyie/scripts.git
source ./../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# KONG_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# exec_shared_services_docker_compose_command is defined in shared_variables.sh
# CONFLUENT_PLATFORM_ALL_IN_ONE_DIR is defined in shared_variables.sh
# CONFLUENT_DOCKER_TAG is defined in shared_variables.sh
# REPOSITORY is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh

source shared_variables.sh

# shows the logs of the shared services
# you can restrict the logs to a particular service by passing in the name of the service
# For exampe `show_logs kong` will only show the logs for the kong service
function show_logs() {
    # $@ represents the args that were passed to the function
    exec_shared_services_docker_compose_command logs -f $@
}

# shows the logs of the shared services
# you can restrict the logs to a particular service by passing in the name of the service
# For exampe `show_logs kong` will only show the logs for the kong service
 # $@ represents the args that were passed to the function
show_logs $@