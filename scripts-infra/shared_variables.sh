#!/bin/sh

KONG_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../docker-kong/compose
INFRA_SCRIPTS_ROOT=`pwd`
CONFLUENT_PLATFORM_ALL_IN_ONE_DIR=`pwd`/../confluent-platform/cp-all-in-one

echo "sourcing ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env"
source ${CONFLUENT_PLATFORM_ALL_IN_ONE_DIR}/.env

QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../../
declare -a QUANTAL_MS_DOCKER_COMPOSE_DIRS=("${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantalex-users"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-auth"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-telephones-service"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-email-service"
                )


