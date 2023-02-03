@echo off

:: Copyright 2021 HCL Technologies
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.


:: This script will load all DX docker images that are accessible 
:: through docker-compose into the local docker registry.
:: In addition to that, the dx.properties file will be updated
:: with the tags of the docker images that were loaded by the script.

:: The script unsets environment variables to run DX in a docker-compose environment

SET SCRIPT_DIR=

SET COMPOSE_PROJECT_NAME=
SET COMPOSE_FILE=
SET DX_HOSTNAME=

SET DX_DOCKER_IMAGE_CORE=
SET DX_DOCKER_IMAGE_RINGAPI=
SET DX_DOCKER_IMAGE_DAM=
SET DX_DOCKER_IMAGE_IMAGE_PROCESSOR=
SET DX_DOCKER_IMAGE_CC=
SET DX_DOCKER_IMAGE_DAM_DB=
SET DX_DOCKER_IMAGE_HAPROXY=
SET DX_DOCKER_IMAGE_PREREQS_CHECKER=