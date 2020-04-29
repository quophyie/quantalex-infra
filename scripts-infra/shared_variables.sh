#!/bin/sh

KONG_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../docker-kong/compose
INFRA_SCRIPTS_ROOT=`pwd`
CONFLUENT_PLATFORM_ALL_IN_ONE_DIR=`pwd`/../confluent-platform/cp-all-in-one

echo "sourcing ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env"
source ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env

SHARED_SERVICES_DOCKER_COMPOSE_COMMAND="docker-compose -f ${KONG_DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml -f ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/docker-compose.yml"

QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../../
declare -a QUANTAL_MS_DOCKER_COMPOSE_DIRS=("${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantalex-users"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-auth"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-telephones-service"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-email-service"
                )

# executes the docker compose command for the shared services
# any arguments that is passed will be appended to the compose command

function exec_shared_services_docker_compose_command() {
    # $@ represents the args that were passed to the function
    local command="${SHARED_SERVICES_DOCKER_COMPOSE_COMMAND} $@"
    echo "Running command ${command}"
    eval ${command}
}


