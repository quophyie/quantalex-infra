#!/bin/sh

# shared quantal infra functions
INFRA_SHARED_FUNCS_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
INFRA_SHARED_FUNCS="${INFRA_SHARED_FUNCS_DIR}/shared_infra_funcs.sh"

# *** NOTE ****
# check_quantal_shared_scripts_dir_exists is defined in shared_infra_funcs.sh
# check_and_exit_if_infra_scripts_root_env_var_not_exist is defined in shared_infra_funcs.sh
# INFRA_SCRIPTS_ROOT will be set up when bin/setup is run

set -e
# Naive try catch
{
 source ${INFRA_SHARED_FUNCS}
 check_quantal_shared_scripts_dir_exists
 check_and_exit_if_infra_scripts_root_env_var_not_exist
} ||
{

 echo "Quantal shared scripts not found!"
 exit 1

}

# Make sure that the scripts repository has been checked out from git
# i.e. from https://github.com/quophyie/scripts.git
source ${INFRA_SCRIPTS_ROOT}/../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# KONG_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# exec_shared_services_docker_compose_command is defined in shared_variables.sh
# CONFLUENT_PLATFORM_ALL_IN_ONE_DIR is defined in shared_variables.sh
# CONFLUENT_DOCKER_TAG is defined in shared_variables.sh
# REPOSITORY is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh

source ${INFRA_SCRIPTS_ROOT}/shared_variables.sh

exec_shared_services_docker_compose_command ps



