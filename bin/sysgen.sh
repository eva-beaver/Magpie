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
 
set -e    # this line will stop the script on error
#set -xv   # this line will enable debug


. $(dirname $0)/_vars.sh
. $(dirname $0)/_common.sh
. $(dirname $0)/_systemDef.sh
. $(dirname $0)/_buildSystem.sh
#. $(dirname $0)/_requires.sh
. $(dirname $0)/_docker.sh
. $(dirname $0)/_logging.sh


function usage() {
    set -e
    cat <<EOM
    ##### sysgen #####
    Script to build systems and build docker environment from a system build file.

    One of the following is required:

    Required arguments:

    Optional arguments:
        -m | --systemDef name   The system definition to build, defaults to current directory
        -d | --debug            Set to 1 to switch on, defaults to off (0)
        -o | --output           Where to output the log to, defaults to current directory

    Requirements:
        git:                Local git installation
        jq:                 Local jq installation

    Examples:
      Build a sample project

        ../bin/sysgen.sh -m mySystemDef.json

    Notes:

EOM

    exit 2
}


echo "⏲️++++++++++++++++++++++++++++++++++++++++++"
echo "⏲️       Starting............"
echo "⏲️++++++++++++++++++++++++++++++++++++++++++"

#if [ $# == 0 ]; then usage; fi

    # check for required software
    require git
    require jq
    require docker
    require docker-compose
    require sdk

    OUTPUT=$(pwd)
    DOCKER="Build"

    SYSTEMDEF_NAME="systenDef.json"
    _SYSTEMDEF=$SYSTEMDEF_NAME
    _DEBUG=0

    # Loop through arguments, two at a time for key and value
    while [[ $# > 0 ]]
    do
        key="$1"
echo $key
        case ${key} in
            -m|--systemDef)
                _SYSTEMDEF="$2"
                shift # past argument
                ;;
            -d|--debug)
                _DEBUG=1
                shift # past argument
                ;;
            -o|--output)
                _OUTPUT="$2"
                shift # past argument
                ;;
            *)
                usage
                exit 2
            ;;
        esac
        shift # past argument or value
    done

    # require a manifest name to be set
    if [ -z "${_SYSTEMDEF}" ]
    then
        usage
    fi

    DEBUG=$_DEBUG
    SYSTEMDEF_NAME=$_SYSTEMDEF

    # check if system definition file exists
    if test -f "$SYSTEMDEF_NAME"; then
        echo "✔️       $SYSTEMDEF_NAME exist"
    else    
        echo "❌        generation failure - [$_SYSTEMDEF_NAME] does not exist!!!!"; exit 1
    fi

    #echo "project: [${PROJECT}]"
    #echo "workDir: ${WORKING_DIRECTORY}"

    loadSystemDef "${SYSTEMDEF_NAME}" 

    _buildSystem
    
    if [[ "$?" -eq 0 ]] ; then

        if [ "$SYSTEMDEF_TYPE_DOCKER_BUILDDOCKERIMAGE" -eq 1 ];then

            if [ "$SYSTEMDEF_TYPE_DOCKERFILE_GENERATE" -eq 1 ];then

                _generateDockerfile
                
            fi
        
            buildDockerImage

            if [ "$SYSTEMDEF_TYPE_DOCKER_STARTDOCKERIMAGE" -eq 1 ];then

                stopDockerProject
                
                rmDockerProject

                if [ "$SYSTEMDEF_TYPE_DOCKER_STARTNETWORK" -eq 1 ];then

                    removeNetwork $SYSTEMDEF_TYPE_DOCKER_NETWORK

                    createNetwork $SYSTEMDEF_TYPE_DOCKER_NETWORK $SYSTEMDEF_TYPE_DOCKER_IPMASK

                fi

                runDockerProject

                if [ "$SYSTEMDEF_TYPE_DOCKER_PUSHDOCKERIMAGE" -eq 1 ];then

                    tagDockerProject

                    pushDockerProject

                else 

                    echo "👌       .....skipping docker tag & push"

                fi

            else 

                echo "👌       .....skipping docker run"

            fi

        else 

            echo "👌       .....skipping docker build"

        fi

    else
	
        echo "❌        build failure - [$_MANIFEST] !!!!!!!!!"; exit 1

    fi

    #RESULT=$(getJsonItem $SYSTEMDEF_NAME '.xxx') && echo $RESULT
    #SYSTEMDEF_TYPE_INFO_ID=$(getJsonItem $SYSTEMDEF_NAME '.info.id') && echo $SYSTEMDEF_TYPE_INFO_ID


    # create a tmp directory to work in
    #TMP_DIR=$(createTempDirectory)
    #echo "tempDir: ${TMP_DIR}"
    #cd ${TMP_DIR}

    # clean up working directory
    #cleanUpTempDirectory ${TMP_DIR}

    echo "👋       Finished!!!"
