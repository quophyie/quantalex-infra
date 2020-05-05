#!/bin/sh

# if INFRA_SCRIPTS_ROOT is empty, set it
if [ -z "${INFRA_SCRIPTS_ROOT}" ]; then

#  get the correct absolute full name of the scripts-infra  directory (i.e. the directory containing this script)
# this makes sure that no matter where this file is sourced from,
# INFRA_SCRIPTS_ROOT will always be set to the correct absolute directory i.e. the directory containing
# this file

# see https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
# for more info
    SOURCE="${BASH_SOURCE[0]}"

    # if this file has been symlinked the code in the while loop will resolve until
    # we the actual directory containing this file is reached
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    INFRA_SCRIPTS_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
fi

KONG_DOCKER_COMPOSE_SCRIPTS_ROOT=${INFRA_SCRIPTS_ROOT}/../docker-kong/compose
CONFLUENT_PLATFORM_ALL_IN_ONE_DIR=${INFRA_SCRIPTS_ROOT}/../confluent-platform/cp-all-in-one

# source the confluent env file
if [[  -d ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR} ]] && [[ -f "${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env" ]]; then
    echo "sourcing ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env"
    source ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env
fi

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


