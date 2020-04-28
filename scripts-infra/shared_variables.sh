#!/bin/sh

KONG_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/compose
INFRA_SCRIPTS_ROOT=`pwd`
CONFLUENT_PLATFORM_ALL_IN_ONE_DIR=`pwf`/../../confluent-platform/cp-all-in-one/cp-all-in-one
QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT=`pwd`/../../
declare -a QUANTAL_MS_DOCKER_COMPOSE_DIRS=("${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantalex-users"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-auth"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-telephones-service"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-email-service"
                )


