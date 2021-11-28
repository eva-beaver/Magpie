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


. $(dirname $0)/_vars.sh
. $(dirname $0)/_common.sh
. $(dirname $0)/_sysfile.sh
. $(dirname $0)/_buildSystem.sh
. $(dirname $0)/_requires.sh
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
        -m | --manifest name    The manifest to build, defaults to current directory
        -d | --debug            Set to 1 to switch on, defaults to off (0)
        -o | --output           Where to output the log to, defaults to current directory

    Requirements:
        git:                Local git installation
        jq:                 Local jq installation

    Examples:
      Build a sample project

        ../bin/build.sh -m mymanifest.json

    Notes:

EOM

    exit 2
}
