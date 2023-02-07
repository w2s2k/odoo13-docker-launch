#!/bin/bash
#
# Copyright (C) 2015 The Gravitee team (http://gravitee.io)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

readonly WORKDIR="$PWD"
readonly DIRNAME=`dirname $0`
readonly PROGNAME=`basename $0`
readonly color_title='\033[31m'
readonly color_text='\033[1;36m'

# OS specific support (must be 'true' or 'false').
declare cygwin=false
declare darwin=false
declare linux=false
declare dc_exec="docker-compose up -d"


welcome(){
    echo 
    echo 
    echo -e "${color_title} 
        ░█████╗░░█████╗░██████╗░░█████╗░░█████╗░  ░░███╗░░██████╗░
        ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗  ░████║░░╚════██╗
        ██║░░██║██║░░██║██║░░██║██║░░██║██║░░██║  ██╔██║░░░█████╔╝
        ██║░░██║██║░░██║██║░░██║██║░░██║██║░░██║  ╚═╝██║░░░╚═══██╗
        ╚█████╔╝╚█████╔╝██████╔╝╚█████╔╝╚█████╔╝  ███████╗██████╔╝
        ░╚════╝░░╚════╝░╚═════╝░░╚════╝░░╚════╝░  ╚══════╝╚═════╝░\033[0m"
    echo
    echo
    echo
}

init_env() {
    local dockergrp
    # define env
    case "`uname`" in
        CYGWIN*)
            cygwin=true
            ;;

        Darwin*)
            darwin=true
            ;;

        Linux)
            linux=true
            ;;
    esac

    # test if docker must be run with sudo
    dockergrp=$(groups | grep -c docker)
    if [[ $darwin == false && $dockergrp == 0 ]]; then
        dc_exec="sudo $dc_exec";
    fi
}


main() {
    welcome
    init_env
    if [[ $? != 0 ]]; then
        exit 1
    fi
    set -e
    pushd $WORKDIR > /dev/null
        echo "Download required files ..."
}

# init port from input parameter
if [ "$1" != "" ]; then
    export NGINX_PORT=$1
else
    export NGINX_PORT=80
fi

main