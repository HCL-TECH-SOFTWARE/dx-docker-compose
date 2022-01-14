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

setlocal enabledelayedexpansion

:: Getting input of file path from the User
set currentDir="%cd%"
set filePath=%1
IF exist %filePath% (
cd %filePath%
set listOfImages[0]=DX_DOCKER_IMAGE_CONTENT_COMPOSER:hcl-dx-content-composer
set listOfImages[1]=DX_DOCKER_IMAGE_IMAGE_PROCESSOR:hcl-dx-image-processor
set listOfImages[2]=DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER:hcl-dx-persistence-node-image
set listOfImages[3]=DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER:hcl-dx-persistence-connection-pool
set listOfImages[4]=DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER:hcl-dx-digital-asset-manager
set listOfImages[5]=DX_DOCKER_IMAGE_RING_API:hcl-dx-ringapi
set listOfImages[6]=DX_DOCKER_IMAGE_CORE:hcl-dx-core
set listOfImages[7]=DX_DOCKER_IMAGE_DESIGN_STUDIO:hcl-dx-design-studio-image

SET DX_DOCKER_IMAGE_CONTENT_COMPOSER=""
SET DX_DOCKER_IMAGE_IMAGE_PROCESSOR=""
SET DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER=""
SET DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER=""
SET DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER=""
SET DX_DOCKER_IMAGE_RING_API=""
SET DX_DOCKER_IMAGE_CORE=""
SET DX_DOCKER_IMAGE_DESIGN_STUDIO=""

    for /l %%i in (0,1,5) do ( 
        SET imageName=!listOfImages[%%i]!
        for /f "tokens=1,2 delims=:" %%a in ("!listOfImages[%%i]!") do (
            IF EXIST %%b*.tar.gz (
                FOR /F "Tokens=*" %%x IN ('dir /b %%b*.tar.gz') do  (
                    for /f "delims=" %%j in ('docker load -i %%~x') do (
                        SET imageNameTag=%%j
                        Call echo !imageNameTag!
                        SET successCheck=!imageNameTag:~0,12!
                        IF "!successCheck!"=="Loaded image" ( 
                            IF %%a==DX_DOCKER_IMAGE_CONTENT_COMPOSER SET DX_DOCKER_IMAGE_CONTENT_COMPOSER=!imageNameTag:~14!
                            IF %%a==DX_DOCKER_IMAGE_IMAGE_PROCESSOR SET DX_DOCKER_IMAGE_IMAGE_PROCESSOR=!imageNameTag:~14!
                            IF %%a==DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER SET DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER=!imageNameTag:~14!
                            IF %%a==DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER SET DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER=!imageNameTag:~14!
                            IF %%a==DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER SET DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER=!imageNameTag:~14!
                            IF %%a==DX_DOCKER_IMAGE_RING_API SET DX_DOCKER_IMAGE_RING_API=!imageNameTag:~14!
                            IF %%a==DX_DOCKER_IMAGE_CORE SET DX_DOCKER_IMAGE_CORE=!imageNameTag:~14!
                            IF %%a==DX_DOCKER_IMAGE_DESIGN_STUDIO SET DX_DOCKER_DESIGN_STUDIO=!imageNameTag:~14!
                        ) ELSE (
                            call echo "Error occured while loading %%b*.tar.gz file into docker"
                        )
                    )
                )
            ) else (
                call echo "WARNING: %%b*.tar.gz file is not available in the provided path"
            )
        )
    )
) else (
echo "ERROR: No such directory exists. Please try again."
cd %currentDir%
EXIT /B
)


Call echo "Updating properties file with image tags"
cd %currentDir%
(for /f "tokens=1* delims==" %%m in (dx.properties) do (
IF %%m==DX_DOCKER_IMAGE_CONTENT_COMPOSER  (
    IF %DX_DOCKER_IMAGE_CONTENT_COMPOSER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_CONTENT_COMPOSER%)
) ELSE IF %%m==DX_DOCKER_IMAGE_IMAGE_PROCESSOR (
    IF %DX_DOCKER_IMAGE_IMAGE_PROCESSOR%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_IMAGE_PROCESSOR%)
) ELSE IF %%m==DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER (
    IF %DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER%)
) ELSE IF %%m==DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER (
    IF %DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER%)
) ELSE IF %%m==DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER (
    IF %DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER%)
) ELSE IF %%m==DX_DOCKER_IMAGE_RING_API (
    IF %DX_DOCKER_IMAGE_RING_API%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_RING_API%)
) ELSE IF %%m==DX_DOCKER_IMAGE_CORE (
    IF %DX_DOCKER_IMAGE_CORE%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_CORE%) 
) ELSE IF %%m==DX_DOCKER_IMAGE_DESIGN_STUDIO (
    IF %DX_DOCKER_IMAGE_DESIGN_STUDIO%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_DESIGN_STUDIO%)    
) else ( echo %%m)
))>result.properties
DEL dx.properties
rename result.properties dx.properties

Call echo "Task completed"
