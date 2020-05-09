#!/usr/bin/env bash

# Check for the existence of INFRA_SCRIPTS_ROOT env var and if it does not exist
# exit script execution
function check_and_exit_if_infra_scripts_root_env_var_not_exist() {

    # Search for the placeholder file .gitinfrakeep which will be available
    # if INFRA_SCRIPTS_ROOT has veeb setup

    if [[ ! -f "${INFRA_SCRIPTS_ROOT}/.gitinfrakeep" ]]; then

        local setUpScriptDir
        # Get the shell executing the script
        local shell
        get_shell shell

        if [[  "${shell}" = "bash" ]]; then

           setUpScriptDir="$( cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1 ; pwd -P )"

        elif [[ "${shell}" = "zsh"  ]]; then
            setUpScriptDir="$( cd "$(dirname "${funcfiletrace[1]}")">/dev/null 2>&1 ; pwd -P )"
        fi

        printf "\nvariable INFRA_SCRIPTS_ROOT not configured\n\n"
        printf "please run ${setUpScriptDir}/bin/setup to configure INFRA_SCRIPTS_ROOT variable\n\n"
        exit  1

   fi

}

# configures the INFRA_SCRIPTS_ROOT environment variables
function configure_infra_scripts_dir_env_var() {

 echo "configuring variable INFRA_SCRIPTS_ROOT ..."
 if [ -z "${INFRA_SCRIPTS_ROOT}" ]; then

# get the correct absolute full name of the scripts-infra  directory (i.e. the directory containing this script)
# this makes sure that no matter where this file is sourced from,
# INFRA_SCRIPTS_ROOT will always be set to the correct absolute directory i.e. the directory containing
# this file


    local source

    # Get the shell executing the script
     local shell
     get_shell shell

     if [[  "${shell}" = "bash" ]]; then
         # see https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
        # for more info
        source="${BASH_SOURCE[0]}"

     elif [[ "${shell}" = "zsh"  ]]; then
         source="$( cd "$(dirname "${funcfiletrace[1]}")">/dev/null 2>&1 ; pwd -P )"
     fi

    local isSymLink=false

    # if this file has been symlinked the code in the while loop will resolve until
    # we the actual directory containing this file is reached
    while [ -h "$source" ]; do # resolve $SOURCE until the file is no longer a symlink
      isSymLink=true
      DIR="$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )"
      source="$(readlink "$source")"
      [[ $source != /* ]] && source="$DIR/$source" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done


#    if [[ ${isSymLink} == "true" ]]; then
#        INFRA_SCRIPTS_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
#    else
#        INFRA_SCRIPTS_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#    fi

    INFRA_SCRIPTS_ROOT="$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )"

   echo "successfully configured variable INFRA_SCRIPTS_ROOT as ${INFRA_SCRIPTS_ROOT} "

 fi

}

# Finds a line containing a given string in a file and inserts the given new
# after the found line
# Args: $1 = the path to the file to search
#       $2 = the string to search for in the file
#       $3 = the string to insert after the found line
function insert_after # file line newText
{

  local file="$1" line="$2" newText="$3"
 # echo "inserting '${newText}' after line  "${line}" in file ${file}"

  if grep -q "${line}" "${file}"; then
    sed -i ".bak" -e "/^$line/a"$'\\\n\\\n'"$newText"$'\n' "$file"
  else
      echo -e "\n${newText}" >> ${file}
  fi
}

# Updates  ${PROFILE} file (defined above) to source this file
function update_profile_with_aliases_source() {

   # local source_line_to_add="\n& # Source Quantal Infra Aliases \n& source ${INFRA_SCRIPTS_ROOT}/setup_aliases.sh\\\n"

    local profile

    get_profile_file profile

    local source_line_to_add="source ${INFRA_SCRIPTS_ROOT}/setup_aliases.sh"
    local comment="# Source Quantal Infra aliases"
    local line_to_insert_source_line_after="source ~\/.bash_profile"
    local infra_scripts_dir_env_var="INFRA_SCRIPTS_ROOT="${INFRA_SCRIPTS_ROOT}""
    local infra_scripts_escaped_path=$(echo ${INFRA_SCRIPTS_ROOT} | sed -e 's|/|\\/|g')
   # local infra_scripts_dir_env_var_pattern=INFRA_SCRIPTS_ROOT=${INFRA_SCRIPTS_ROOT}
    local infra_scripts_dir_env_var_pattern="INFRA_SCRIPTS_ROOT=${infra_scripts_escaped_path}"

     if ! grep -q "${source_line_to_add}" "${profile}"; then

      # update profile
    echo "updating profile with command '${source_line_to_add}'"

        if grep -q "${line_to_insert_source_line_after}" "${profile}"; then
           # Insert alias sourcing command after the source bash_profile line in ${PROFILE} file
           # Note that this is done in reverse order
            insert_after ${profile} "${line_to_insert_source_line_after}" "${comment}"
            insert_after ${profile} "${comment}" "${infra_scripts_dir_env_var}"
            insert_after ${profile} "${infra_scripts_dir_env_var_pattern}" "${source_line_to_add}"
        else
            # Insert alias sourcing command on last last line in ${PROFILE} file
            insert_after ${profile} "${line_to_insert_source_line_after}" "${comment}"
            insert_after ${profile} "${comment}" "${infra_scripts_dir_env_var}"
            insert_after ${profile} "${infra_scripts_dir_env_var_pattern}" "${source_line_to_add}"
        fi
    fi
}

# Returns the profile file used in the shell
#   Arg:
#       $1: The profile file returned from this function. the caller of this function must provide a variable which
#           be set by this function to the file name of the profile
#
get_profile_file() {

    local  __resultvar=$1
    bashProfile=~/.bash_profile
    zshProfile=~/.zshrc

    local shell

    # Get the shell running the script
    get_shell shell

    if [[ "${SHELL}" = "/bin/zsh" ]]; then

        profile=${zshProfile}

    elif [[ "${SHELL}" = "/bin/bash" ]]; then

        profile=${bashProfile}
    fi

    # this is the value that is returned to the caller of this function

    eval $__resultvar="'${profile}'"

}

# This returns the running shell
# Args:
#       $1: The value returned from this function. This is the currently running shell.
#            the caller of this function must provide a variable which
#            be set by this function to the name of the shell executing the script
#

function get_shell(){

    local  __resultvar=$1
    local profileShell

    if test -n "$ZSH_VERSION"; then
      profileShell=zsh
    elif test -n "$BASH_VERSION"; then
      profileShell=bash
    elif test -n "$KSH_VERSION"; then
      profileShell=ksh
    elif test -n "$FCEDIT"; then
      profileShell=ksh
    elif test -n "$PS3"; then
      profileShell=unknown
    else
      profileShell=sh
    fi

    # this is the value that is returned to the caller of this function

    eval $__resultvar="'${profileShell}'"

}

# This checks whether the quantal shared scripts directory exists
# The quantal shared scripts directory is clone of the git repository https://github.com/quophyie/scripts.git
function check_quantal_shared_scripts_dir_exists() {

 # for bash shells
 local shell
 local projectDir

# Get the shell executing the script
 get_shell shell

 if [[  "${shell}" = "bash" ]]; then
     projectDir="$( cd "$(dirname "${BASH_SOURCE[0]}")"/../.. >/dev/null 2>&1 ; pwd -P )"

 elif [[ "${shell}" = "zsh"  ]]; then
     projectDir="$( cd "$(dirname "${funcfiletrace[1]}")"/../.. >/dev/null 2>&1 ; pwd -P )"
 fi

local quantalSharedScriptsDir="${projectDir}/scripts"

 if [[ ! -d ${quantalSharedScriptsDir} ]]; then

    printf "\nQuantal shared scripts directory ${quantalSharedScriptsDir} does not exist.\n"

    echo "Please clone the quantal shared scripts project into ${quantalSharedScriptsDir} using command below and try again."

    printf "\n\n git clone https://github.com/quophyie/scripts.git ${quantalSharedScriptsDir} \n\n"

    return 1
 fi

}

