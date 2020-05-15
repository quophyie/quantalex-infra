#!/bin/sh

# shared quantal infra functions
INFRA_SHARED_FUNCS_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
INFRA_SHARED_FUNCS="${INFRA_SHARED_FUNCS_DIR}/shared_infra_funcs.sh"

# *** NOTE ****
# check_quantal_shared_scripts_dir_exists is defined in shared_infra_funcs.sh
# check_and_exit_if_infra_scripts_root_env_var_not_exist is defined in shared_infra_funcs.sh
# INFRA_SCRIPTS_ROOT will be set up when bin/setup is run

# set -e
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

KONG_DOCKER_COMPOSE_SCRIPTS_ROOT=${INFRA_SCRIPTS_ROOT}/../docker-kong/compose
ELASTICSEARCH_DOCKER_COMPOSE_DIR=${INFRA_SCRIPTS_ROOT}/../docker-elasticsearch/compose
CONFLUENT_PLATFORM_ALL_IN_ONE_DIR=${INFRA_SCRIPTS_ROOT}/../confluent-platform/cp-all-in-one

# source the confluent env file
if [[  -d ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR} ]] && [[ -f "${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env" ]]; then
    echo "sourcing ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env"
    source ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env
fi

SHARED_SERVICES_DOCKER_COMPOSE_COMMAND="docker-compose -f ${KONG_DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml \
-f ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/docker-compose.yml \
-f ${ELASTICSEARCH_DOCKER_COMPOSE_DIR}/docker-compose.yml "

QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT="${INFRA_SCRIPTS_ROOT}/../../"
declare -a QUANTAL_MS_DOCKER_COMPOSE_DIRS=("${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantalex-users"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-auth"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-telephones-service"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-email-service"
                )

# executes the docker compose command for the shared services
# any arguments that is passed will be appended to the compose command

function exec_shared_services_docker_compose_command() {
    # $@ represents the args that were passed to the function
    local command="${SHARED_SERVICES_DOCKER_COMPOSE_COMMAND} $@ "
    echo "Running command ${command}"
    eval ${command}
}


