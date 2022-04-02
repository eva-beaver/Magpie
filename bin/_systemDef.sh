#!/usr/bin/env bash
#/*
#* Copyright 2014-2021 the original author or authors.
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#*     http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#*/
 
. $(dirname $0)/_common.sh
. $(dirname $0)/_vars.sh


function loadSystemDef {

    local SYSTEMDEF_NAME=${1}

    echo "⏲️       Loading System Definition [$SYSTEMDEF_NAME]"

    SYSTEMDEF_VERSION=$(getJsonItem $SYSTEMDEF_NAME '.version' $SYSTEMDEF_VERSION)
    SYSTEMDEF_DESCRIPTION=$(getJsonItem $SYSTEMDEF_NAME '.description' $SYSTEMDEF_DESCRIPTION)
    SYSTEMDEF_INFO_ID=$(getJsonItem $SYSTEMDEF_NAME '.info.id' $SYSTEMDEF_INFO_ID)
    SYSTEMDEF_INFO_NAME=$(getJsonItem $SYSTEMDEF_NAME '.info.name' $SYSTEMDEF_INFO_NAME)
    SYSTEMDEF_INFO_REPOSITORY=$(getJsonItem $SYSTEMDEF_NAME '.info.repository' $SYSTEMDEF_INFO_REPOSITORY)
    SYSTEMDEF_INFO_DESCRIPTION=$(getJsonItem $SYSTEMDEF_NAME '.info.description' $SYSTEMDEF_INFO_DESCRIPTION)
    SYSTEMDEF_INFO_ENVIRONMENT=$(getJsonItem $SYSTEMDEF_NAME '.info.environment' $SYSTEMDEF_INFO_ENVIRONMENT)

    # Build an array from each item in requires array
    ARR_SERVICES_NAME=(`echo "$(get_array_items $SYSTEMDEF_NAME '.services' '.name')"`);
    ARR_SERVICES_DESCRIPTION=(`echo "$(get_array_items $SYSTEMDEF_NAME '.services' '.description')"`);
    ARR_SERVICES_TYPE=(`echo "$(get_array_items $SYSTEMDEF_NAME '.services' '.type')"`);
    ARR_SERVICES_VERSION=(`echo "$(get_array_items $SYSTEMDEF_NAME '.services' '.version')"`);

#    echo "......" ${ARR_SERVICES_NAME[0]}
#    echo "......" ${ARR_SERVICES_NAME[1]}

    if [ $DEBUG -eq 1 ];then
        printSystemDef
    fi

    _validateSystemDef

    echo "✔️       SystemDef Loaded"

}

function temp {

    echo `jq '.services[1]' $SYSTEMDEF_NAME`

    echo "--------------------"
    service="$(cat $SYSTEMDEF_NAME | jq .services[0])"
    echo ">>>>> $service"
    service="$(cat $SYSTEMDEF_NAME | jq .services[1])"
    echo ">>>>> $service"
    #echo `jq '.interfaces[1]' $service`

    local interfaces="$(echo $service | jq -r '.interfaces')"
    echo "interfaces >>>>>" $interfaces

    local interface="$(echo $interfaces | jq -r '.[2]')"
    echo "interface >>>>>" $interface

    echo $(cat "$SYSTEMDEF_NAME"| jq -r ".services"'|keys_unsorted[] as $key|"export \($key)=\(.[$key])"')
    echo $(doExportJsonSectionVars $SYSTEMDEF_NAME 'description')

    #for k in $(jq '.children.values | keys | .[]' $SYSTEMDEF_NAME); do
    #    value=$(jq -r ".children.values[$k]" $SYSTEMDEF_NAME);
    #    name=$(jq -r '.path.name' <<< "$value");
    #    type=$(jq -r '.type' <<< "$value");
    #    action=$(jq -r '.actiom' <<< "$value");
    #    echo  "$name" "$type" "$action";
    #    printf '%s\t%s\t%s\n' "$name" "$type" "$action";
    #done | column -t -s$'\t'

    xxx="$(echo $service | jq '.[] ' '|' '.type')"

    #xxx=(`echo "$(get_array_items $interfaces '.services' '.interfaces')"`);

    echo "xxxxx" xxx


    # Show what is required for the docker-compose manifest
    for index in "${!ARR_SERVICES_INTERFACES[@]}"
    do
        echo "$index ${ARR_SERVICES_INTERFACES[index]} ${ARR_SERVICES_INTERFACES[index]}"
    done

    local arr_volName=(`echo "$(__get_array_items_from_array  $SYSTEMDEF_NAME '.name')"`);

    local data="$(get_array_items $SYSTEMDEF_NAME '.services' '.name')"
   
    echo "Data" $data

    for row in $(echo "${data}" | jq -r '.[] | @base64'); do
        _jq() {
          echo ${row} | base64 --decode | jq -r "name"
        }

        echo "$(_jq "name")"
    done


}
function _validateSystemDef {
#Todo:

    echo "⏳      Validating SystemDef [$SYSTEMDEF_NAME]"

    echo "✔️       SystemDef is valid"

}
#
#------------------------------------------------------------------------------
# usage example:
# doExportJsonSectionVars cnf/env/dev.env.json '.env.virtual.docker.spark_base'
#------------------------------------------------------------------------------
doExportJsonSectionVars(){

   json_file="$1"
   shift 1;
   test -f "$json_file" || echo "the json_file: $json_file does not exist !!! Nothing to do" && exit 1

   section="$1"
   test -z "$section" && echo "the section in doExportJsonSectionVars is empty !!! nothing to do !!!" && exit 1
   shift 1;

   while read -r l ; do
      eval $l ;
   done < <(cat "$json_file"| jq -r "$section"'|keys_unsorted[] as $key|"export \($key)=\(.[$key])"')
}

function printSystemDef {

    echo "version [$SYSTEMDEF_VERSION]"
    echo "description [$SYSTEMDEF_DESCRIPTION]"
    echo "info.id [$SYSTEMDEF_INFO_ID]"
    echo "info.name [$SYSTEMDEF_INFO_NAME]"
    echo "info.repository [$SYSTEMDEF_INFO_REPOSITORY]"
    echo "info.description [$SYSTEMDEF_INFO_DESCRIPTION]"
    echo "info.environment [$SYSTEMDEF_INFO_ENVIRONMENT]"
 
    echo ">>>>>>>Services to generate"

    # Show what is required for the docker-compose manifest
    for index in "${!ARR_SERVICES_NAME[@]}"
    do
        echo "Service $index ${ARR_SERVICES_NAME[index]}"
        service="$(cat $SYSTEMDEF_NAME | jq .services[$index])"
        echo ">>>>> $service"
   done

}


__get_array_items_from_array() {

    local data="$(get_array_items $1 '.services' '.name')"
   
    for row in $(echo "${data}" | jq -r '.[] | @base64'); do
        _jq() {
          echo ${row} | base64 --decode | jq -r ${1}
        }

        echo "$(_jq $2)"
    done

}
