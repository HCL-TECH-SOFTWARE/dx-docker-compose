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

:: Thise script sets up necessary environment variables to run DX in a docker-compose environment

FOR /F "tokens=1,2 delims==" %%A IN (dx.properties) DO (
    IF "%%A"=="DX_DOCKER_IMAGE_CONTENT_COMPOSER" SET DX_DOCKER_IMAGE_CONTENT_COMPOSER=%%B
    IF "%%A"=="DX_DOCKER_IMAGE_CORE" SET DX_DOCKER_IMAGE_CORE=%%B
    IF "%%A"=="DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER" SET DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER=%%B
    IF "%%A"=="DX_DOCKER_IMAGE_DATABASE_DIGITAL_ASSET_MANAGER" SET DX_DOCKER_IMAGE_DATABASE_DIGITAL_ASSET_MANAGER=%%B
    IF "%%A"=="DX_DOCKER_IMAGE_IMAGE_PROCESSOR" SET DX_DOCKER_IMAGE_IMAGE_PROCESSOR=%%B
    IF "%%A"=="DX_DOCKER_IMAGE_RING_API" SET DX_DOCKER_IMAGE_RING_API=%%B
)

SET SCRIPT_DIR=%cd%

:: this defines a name prefix that all docker services and containers will inherit
SET COMPOSE_PROJECT_NAME=dx
:: this tells docker-compose the name of the docker-compose file (the default name docker-compose.yaml was changed to prevent running it without a proper environment setup)      
SET COMPOSE_FILE=%SCRIPT_DIR%\dx.yaml

 :: external hostname of dx environment. This normally is just localhost, but may be changed if not running local
SET DX_HOSTNAME=localhost

:: docker image versions
SET DX_DOCKER_IMAGE_CC=%DX_DOCKER_IMAGE_CONTENT_COMPOSER%
SET DX_DOCKER_IMAGE_CORE=%DX_DOCKER_IMAGE_CORE%
SET DX_DOCKER_IMAGE_DAM=%DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER%
SET DX_DOCKER_IMAGE_DAM_DB=%DX_DOCKER_IMAGE_DATABASE_DIGITAL_ASSET_MANAGER%
SET DX_DOCKER_IMAGE_IMAGE_PROCESSOR=%DX_DOCKER_IMAGE_IMAGE_PROCESSOR%
SET DX_DOCKER_IMAGE_RINGAPI=%DX_DOCKER_IMAGE_RING_API%

echo ""
echo "##################################"
echo "Docker-compose environment set to:"
echo ""
echo "COMPOSE_PROJECT_NAME=%COMPOSE_PROJECT_NAME%"
echo "COMPOSE_FILE=%COMPOSE_FILE%"
echo "DX_HOSTNAME=%DX_HOSTNAME%"
echo "DX_DOCKER_IMAGE_CORE=%DX_DOCKER_IMAGE_CORE%"
echo "DX_DOCKER_IMAGE_RINGAPI=%DX_DOCKER_IMAGE_RINGAPI%"
echo "DX_DOCKER_IMAGE_DAM=%DX_DOCKER_IMAGE_DAM%"
echo "DX_DOCKER_IMAGE_DAM_DB=%DX_DOCKER_IMAGE_DAM_DB%"
echo "DX_DOCKER_IMAGE_IMAGE_PROCESSOR=%DX_DOCKER_IMAGE_IMAGE_PROCESSOR%"
echo "DX_DOCKER_IMAGE_CC=%DX_DOCKER_IMAGE_CC%"
echo ""
echo "##################################"
