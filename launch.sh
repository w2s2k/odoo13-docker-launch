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
        mkdir -p etc
        curl -L https://raw.githubusercontent.com/w2s2k/odoo13-docker-launch/main/docker-compose.yml -o "docker-compose.yml"
        curl -L https://raw.githubusercontent.com/w2s2k/odoo13-docker-launch/main/.env.local -o ".env"
        cd etc && { curl -L https://raw.githubusercontent.com/w2s2k/odoo13-docker-launch/main/etc/odoo.conf -o "odoo.conf" ; cd -; }
        awk -v ADMIN_PASSWORD="$ADMIN_PASSWORD" '{sub("admin_passwd_value",ADMIN_PASSWORD)} {print}' ./etc/odoo.conf > temp.txt && mv temp.txt ./etc/odoo.conf
        awk -v POSTGRES_PORT="$POSTGRES_PORT" '{sub("db_port_value",POSTGRES_PORT)} {print}' ./etc/odoo.conf > temp.txt && mv temp.txt ./etc/odoo.conf
        envsubst < .env
        echo
        echo "Launch Odoo 13 on port $ODOO_PORT ..."
        echo "Launch Postgres 11.6 on port $POSTGRES_PORT ..."
        echo "Odoo config file with admin password: $ADMIN_PASSWORD"
        $dc_exec
    popd > /dev/null
}

# init port from input parameter
if [ "$1" != "" ]; then
    export ODOO_PORT=$1
else
    export ODOO_PORT=8069
fi
if [ "$2" != "" ]; then
    export POSTGRES_PORT=$2
else
    export POSTGRES_PORT=5432
fi

if [ "$3" != "" ]; then
    ADMIN_PASSWORD=$3
else
    ADMIN_PASSWORD=$(openssl rand -hex 20);
fi

main