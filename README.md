# Quantal  Infrastructure Config

## Setup

1. Create a folder to setup your project

```bash
$ mkdir myproject

$ cd myproject

```

2. Clone the scripts project ``https://github.com/quophyie/scripts.git``. It contains scripts
that are required by the ``Quantal Infrastructure`` project

```bash
$ git clone https://github.com/quophyie/scripts.git .
```

3. Clone this project 

```bash
$ git clone https://github.com/quophyie/quantalex-infra.git .

$ cd quantalex-infra

```

4. Run bin/setup

```bash
$ cd scripts/infra

$ bin/setup

```

The setup script will setup a few aliases for you and possibly some environment variables for
you of which the most important is **`INFRA_SCRIPTS_ROOT`** which points to the absolute path 
of `Quantal Infrastructure` project `script-infra` directory (i.e. **`myproject/scripts-infra`** in this example). 

**LOOK OUT FOR MESSAGES OUTPUT BY THE SETUP SCRIPT**

You may be required to source a few files to complete the environment variable setup

5. Source **``~/.zshrc``** if you are using `ZSH` or source **``~/.bash_profile``** if you are using
**`bash`** as your shell

6. Source any files that the setup script instructs you to do



7. Test that all setup has worked correctly, run the infrastructure with the following alias

```bash
$ run_quantal_infra

```

Thats all folks!!


##  Quantal Infrastructure Platform Containers and Quantal Microservices

There is reference made to both `The Quantal Infrastructure platform containers (services)` and `Quantal Microservices`
in this document.
The difference between `The Quantal Infrastructure platform containers (services)` and `Quantal Microservices`
is explained below

###  Quantal Infrastructure Platform Containers

The Quantal Infrastructure platform containers (services) is made up of several
3rd party platforms. 

These are

- [Confluent Platform](https://docs.confluent.io/current/getting-started.html)
- [Kong](https://konghq.com/)  
- [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)

**NOTE** More services may be added to the The Quantal Infrastructure platform containers (services) as
and when the platform grows to require them

###  Quantal Microservices

The Quantal Microservices are Quantal microservice projects (e.g [Quantal Auth Microservice](https://github.com/quophyie/quantal-auth)) which are you usually git cloned
 into locations such `myproject`
 
 These projects can have any directory structure they desire but they must follow the following rules
 
 1. There must be a `docker/compose/docker-compose.yml` file in the microservice project (e.g. `myproject/quantal-auth/docker/compose/docker-compose.yml`)
 
 2. There must be a `scripts` directory at the root of the microservice project directory  (e.g. `myproject/quantal-auth/scripts`)
 
 3. The `scripts` directory **must** contain the following files `build_run_docker_microservice_containers.sh`
 and `variables.sh` i.e.  `myproject/quantal-auth/scripts/build_run_docker_microservice_containers.sh` and
 `myproject/quantal-auth/scripts/variables.sh`
 
 4.  The `myproject/quantal-auth/scripts/variables.sh` file contains environment variables to be 
 passed to the container. **THIS WILL BE DEPRECATED IN FAVOUR OF ENV FILES SOON** 
 
 ```bash
    #!/bin/bash
    
    #The variables that need to be changed for every new microservice
    # Change the variables below to match the service for the MS BEING DEPLOYED
    #The db container name
    DB_CONTAINER_NAME=quantal_auth_db
    
    # the db server port that is exposed to the host / outside world
    DB_PORT_EXPOSED_ON_HOST=5436
    
    # the db server port that is exposed on the container network i.e. (the default host:port on the container side)
    DB_PORT_EXPOSED_ON_DB_CONTAINER=5432
    
    # the web app server port that is exposed to the host / outside world
    WEB_APP_PORT=9000
    
    MS_NAME=$(echo $(pwd) | rev | cut -d'/' -f 2 | rev)
    
    # for node apps only
    NODE_ENV=development
```
 
 5. The `myproject/quantal-auth/scripts/build_run_docker_microservice_containers.sh` file must have 
 the following content. 
 
 ````bash
     #!/bin/bash
     
     source ${INFRA_SCRIPTS_ROOT}/../../scripts/docker-scripts/common_funcs.sh
     check_and_source_file ~/.bash_profile
     
     BUILD_CONTAINER=$1
     COMPOSE_UP_OPTS=$2
     MS_SERVICE_TYPE=nodejs
     build_start_microservice_containers variables.sh ${MS_SERVICE_TYPE} ${BUILD_CONTAINER} ${COMPOSE_UP_OPTS}
 ````
 
 ###  Making The Quantal Infrastructure Platform aware of Quantal Microservices
 
 By default, the Quantal Infrastructure Platform is not aware of Quantal microservices. This means
 that aliases (e.g.`run_quantal_ms_and_infra` **see below** ) that target the Quantal microservices 
 will not work. 
 
 To make the Quantal Infrastructure Platform aware of a 
 Quantal microservices (e.g. a new service called `my-new-service` located in `myproject` directory),
 do the following
 
 **!! THE FOLLOWING WILL BE DEPRECATED SOON AS IT DOES NOT FOLLOW THE OPEN CLOSED PRINCIPLE !!**
 
 - Open file `${INFRA_SCRIPTS_ROOT}/shared_variables.sh` i.e. `myproject/quantal-infra/scripts-infra/shared_variables.sh`
 
 - Locate the `QUANTAL_MS_DOCKER_COMPOSE_DIRS` array variable
 
 - add the name of the directory that contains the microservice to 
 the `QUANTAL_MS_DOCKER_COMPOSE_DIRS` array variable e.g. 
 ```bash
declare -a QUANTAL_MS_DOCKER_COMPOSE_DIRS=("${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantalex-users"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-auth"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-telephones-service"
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}quantal-email-service"
                
                # This is the new service that we added!!
                "${QUANTAL_MS_DOCKER_COMPOSE_SCRIPTS_ROOT}my-new-service"
                )
```
 
 **For the above to work, `my-new-service` must be located at `myproject/my-new-service`**

After the above configuration, the Quantal Infrastructure Platform will be aware of `my-new-service`
and aliases which target Quantal microservices such as `run_quantal_ms_and_infra` will pick up `my-new-service`


# Aliases

The setup above configures your environment to run the Quantal Infrastructure containers (services)
as well as the Quantal specific microservices. 
It also creates some very useful aliases which will enhance and make development faster.
Once the setup above has been completed, these aliases can be called from anywhere on your system
and not necessarily the Quantal Infrastructure project directory ie. (`myproj\quantal-infra`)

 - **run_quantal_ms_and_infra** - Runs all the quantal containers that form the base infrastructure 
                                    platform (e.g. kafka, kong etc) and the Quantal microservices
  
 - **run_quantal_infra** - Runs all the quantal containers that form the base infrastructure 
                            platform (e.g. kafka, kong etc) **only**
                            
 - **stop_remove_quantal_infra** - Stops and removes all containers that form the Quantal 
                                   infrastructure  **only**. The is effectively a `docker-compose down` command
                                   
 - **stop_remove_quantal_ms_and_infra** - Stops and removes all containers that form the Quantal 
                                          infrastructure  and also all quantal microservices . 
                                          The is effectively a `docker-compose down` command
                                          
 - **stop_quantal_infra** - Stops all containers that form the Quantal 
                            infrastructure  **only**. The is effectively a `docker-compose stop` command 
                            
 - **stop_quantal_ms_and_infra** - Stops all containers that form the Quantal infrastructure
                                   and also all quantal microservices . 
                                   The is effectively a `docker-compose stop` command 
                                   
 - **view_quantal_infra** - Shows the status of the Quantal infrastracture containers
                            The is effectively a `docker-compose ps` command 
                            
 - **view_quantal_ms_and_infra**  - Shows the status of the Quantal infrastracture containers and the
                                    Quantal Microservices
                                    The is effectively a `docker-compose ps` command 
                                    
 - **view_quantal_infra_logs** -  Shows the logs of the Quantal infrastracture containers **only**
                                  This alias performs identical operations as **`show_quantal_infra_logs`**    
                                  The is effectively a `docker-compose logs -f` command 
                                  
 - **show_quantal_infra_logs** - Shows the logs of the Quantal infrastracture containers **only**
                                 This alias performs identical operations as **`view_quantal_infra_logs`**    
                                 The is effectively a `docker-compose logs -f` command 
                                 
 - **build_quantal_ms_and_infra** - this builds and runs all containers that form the Quantal Infrastructure
                                    platform and Quantal specific microservices

With the exception of `build_quantal_ms_and_infra`, all the aliases listed above that target just
the Quantal Infrastructure platform services e.g. (`show_quantal_infra_logs`) can be targeted at 
specific services by passing the service name(s) as arguments. For example

```bash
$ show_quantal_infra_logs kong zookeeper
```
