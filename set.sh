#!/bin/bash

# Copyright 2021 HCL Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The script sets up necessary environment variables to run DX in a docker-compose environment

function prop {
    grep "${1}" dx.properties|cut -d'=' -f2
}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export COMPOSE_PROJECT_NAME=dx            # this defines a name prefix that all docker services and containers will inherit
export COMPOSE_FILE=$SCRIPT_DIR/dx.yaml   # this tells docker-compose the name of the docker-compose file (the default name docker-compose.yaml was changed to prevent running it without a proper environment setup)

export DX_HOSTNAME=localhost              # external hostname of dx environment. This normally is just localhost, but may be changed if not running local

# docker image versions
export DX_DOCKER_IMAGE_CC=$(prop 'DX_DOCKER_IMAGE_CONTENT_COMPOSER')
export DX_DOCKER_IMAGE_CORE=$(prop 'DX_DOCKER_IMAGE_CORE')
export DX_DOCKER_IMAGE_DAM=$(prop 'DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER')
export DX_DOCKER_IMAGE_DAM_DB_NODE=$(prop 'DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER')
export DX_DOCKER_IMAGE_DAM_DB_CONNECTION_POOL=$(prop 'DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER')
export DX_DOCKER_IMAGE_IMAGE_PROCESSOR=$(prop 'DX_DOCKER_IMAGE_IMAGE_PROCESSOR')
export DX_DOCKER_IMAGE_RINGAPI=$(prop 'DX_DOCKER_IMAGE_RING_API')
export DX_DOCKER_IMAGE_DS=$(prop 'DX_DOCKER_IMAGE_DESIGN_STUDIO')
export DX_DOCKER_IMAGE_HAPROXY=$(prop 'DX_DOCKER_IMAGE_HAPROXY')
export DX_DOCKER_IMAGE_PREREQS_CHECKER=$(prop 'DX_DOCKER_IMAGE_PREREQS_CHECKER')

echo ""
echo "##################################"
echo "Docker-compose environment set to:"
echo ""
echo "COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME"
echo "COMPOSE_FILE=$COMPOSE_FILE"
echo "DX_HOSTNAME=$DX_HOSTNAME"
echo "DX_DOCKER_IMAGE_CORE=$DX_DOCKER_IMAGE_CORE"
echo "DX_DOCKER_IMAGE_RINGAPI=$DX_DOCKER_IMAGE_RINGAPI"
echo "DX_DOCKER_IMAGE_DAM=$DX_DOCKER_IMAGE_DAM"
echo "DX_DOCKER_IMAGE_DAM_DB_NODE=$DX_DOCKER_IMAGE_DAM_DB_NODE"
echo "DX_DOCKER_IMAGE_DAM_DB_CONNECTION_POOL=$DX_DOCKER_IMAGE_DAM_DB_CONNECTION_POOL"
echo "DX_DOCKER_IMAGE_IMAGE_PROCESSOR=$DX_DOCKER_IMAGE_IMAGE_PROCESSOR"
echo "DX_DOCKER_IMAGE_CC=$DX_DOCKER_IMAGE_CC"
echo "DX_DOCKER_IMAGE_DS=$DX_DOCKER_IMAGE_DS"
echo "DX_DOCKER_IMAGE_HAPROXY=$DX_DOCKER_IMAGE_HAPROXY"
echo "DX_DOCKER_IMAGE_PREREQS_CHECKER=$DX_DOCKER_IMAGE_PREREQS_CHECKER"
echo ""
echo "##################################"
