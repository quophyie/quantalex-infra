#!/usr/bin/env bash

# if INFRA_SCRIPTS_ROOT is empty, set it
echo "setting up aliases ..."

# shared quantal infra functions
INFRA_SHARED_FUNCS_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
INFRA_SHARED_FUNCS="${INFRA_SHARED_FUNCS_DIR}/shared_infra_funcs.sh"

# *** NOTE ****
# check_quantal_shared_scripts_dir_exists is defined in shared_infra_funcs.sh
# check_and_exit_if_infra_scripts_root_env_var_not_exist is defined in shared_infra_funcs.sh

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

source ${INFRA_SCRIPTS_ROOT}/shared_variables.sh

START_DIR=`pwd`

function set_orig_dir() {
   START_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" >/dev/null 2>&1 && pwd )"
   echo "START_DIR: ${START_DIR}"
}

function source_profiles() {
 echo "sourcing ${PROFILE} ..."
 source ${PROFILE}

}

function go_to_orig_dir() {
    cd ${START_DIR}
}

function go_to_infra_scripts_dir() {
    cd ${INFRA_SCRIPTS_ROOT}
}

# creates an alias such as
# alias run_all_quantal_servicies="go_to_infra_scripts_dir && source ./run_all_services_docker.sh & go_to_orig_dir"
# Args:
#     $1 = the name of the alias
#     $2 = the path to the file that contains the alias definition
function create_alias() {

  local internalAliasFunctionName=__$1
  local fileName=$2
  # we define function that gets called in this string format when we call our alias in this way so that we can pass
  # arguments to the alias.
  # aliases do not normally allow arguments passing but this hack works around that
  local func='function '${internalAliasFunctionName}'() {
        set_orig_dir;
        go_to_infra_scripts_dir;

        # Shift one here cos the 1st arg is the alias name of this alias func and we cant pass that
        # to docker-compose
        shift 1;
        # get the args that were passed to the alias and pass them as args to the alias function file
        local args=$@
        source "'${fileName}'" ${args} & go_to_orig_dir;
        unset -f '${internalAliasFunctionName}';
    };
    '
   # creates an alias such as
   # alias run_all_quantal_servicies="go_to_infra_scripts_dir && source ./run_all_services_docker.sh & go_to_orig_dir"
   # Note that our alias definition calls the function defined above and passes any args passed to the alias
   # to the function defined in the func variable
   # aliases do not normally allow arguments passing but defining a function as shown above and passing
   # the args to the function is a hack that gets around this problem

    alias $1="${func} ${internalAliasFunctionName}"
}

# Configures the quantal infra aliases
function configure_aliases() {
    create_alias run_quantal_ms_and_infra '${INFRA_SCRIPTS_ROOT}/run_all_services_docker.sh'
    create_alias run_quantal_infra '${INFRA_SCRIPTS_ROOT}/run_shared_services_docker.sh'
    create_alias stop_remove_quantal_infra '${INFRA_SCRIPTS_ROOT}/stop_and_remove_shared_running_service_containers_docker.sh'
    create_alias stop_remove_quantal_ms_and_infra '${INFRA_SCRIPTS_ROOT}/stop_and_remove_running_service_containers_docker.sh'
    create_alias stop_quantal_infra '${INFRA_SCRIPTS_ROOT}/stop_running_shared_services_docker.sh'
    create_alias stop_quantal_ms_and_infra '${INFRA_SCRIPTS_ROOT}/stop_running_services_docker.sh'
    create_alias view_quantal_infra '${INFRA_SCRIPTS_ROOT}/view_shared_running_services_docker.sh'
    create_alias view_quantal_ms_and_infra '${INFRA_SCRIPTS_ROOT}/view_running_services_docker.sh'
    create_alias view_quantal_infra_logs '${INFRA_SCRIPTS_ROOT}/show_shared_services_log.sh'
    create_alias show_quantal_infra_logs '${INFRA_SCRIPTS_ROOT}/show_shared_services_log.sh'
    create_alias build_quantal_ms_and_infra '${INFRA_SCRIPTS_ROOT}/build_and_run_all_services_docker.sh'
}

configure_aliases
update_profile_with_aliases_source
#source_profiles
echo "finished setting up aliases"


