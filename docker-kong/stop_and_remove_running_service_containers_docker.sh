#!/bin/sh
# This script will stop all containers and will remove images associated with the
# microservice containers i.e. quantal* containers

source ././../../scripts/docker-scripts/common_funcs.sh
check_and_source_file ~/.bash_profile

# *** NOTE ****
# DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT is defined in shared_variables.sh
# QUANTAL_MS_DOCKER_COMPOSE_DIRS is defined in shared_variables.sh
source shared_variables.sh


    ## now loop through the above array
    for MS_DOCKER_COMPOSE_DIR in "${QUANTAL_MS_DOCKER_COMPOSE_DIRS[@]}"
    do
       echo "IN $MS_DOCKER_COMPOSE_DIR"
       COMMAND="docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml stop"

       # Get the container ids
       CONTAINER_IDS=(`docker-compose -f ${MS_DOCKER_COMPOSE_DIR}/docker/compose/docker-compose.yml ps -q`)

       for CONTAINER_ID in "${CONTAINER_IDS[@]}"
        do

            # Get the container name from container id
            CONTAINER_NAME=`docker ps --filter "id=${CONTAINER_ID}" --format "{{.Names}}"`

            # Get the image id
            CONTAINER_IMAGE_ID=`docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Image}}"`
            echo "Removing container with Name: ${CONTAINER_NAME} and CONTAINER_ID: ${CONTAINER_ID}"
            #docker stop ${CONTAINER_ID}
            #docker rm -f ${CONTAINER_NAME}

            if [ -z "${CONTAINER_ID}" ];then
               echo "No Container Id"
            else
                echo "Removing container with Id ${CONTAINER_ID}"
                docker stop ${CONTAINER_ID}

                # Remove the image
                docker rmi -f ${CONTAINER_IMAGE_ID}
                #echo "Stopped container with Id ${CONTAINER_ID}"
                echo "Stopped and removed Container named: ${CONTAINER_NAME} with Id ${CONTAINER_ID}"
            fi

        done

       eval "cd ${DOCKER_COMPOSE_SCRIPTS_ROOT}"
    done

COMMAND="docker-compose -f ${DOCKER_COMPOSE_SCRIPTS_ROOT}/docker-compose.yml down"
echo "\nRunning command $COMMAND\n"
eval ${COMMAND}
