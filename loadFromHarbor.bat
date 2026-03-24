:: Copyright 2021, 2023 HCL Technologies
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

@echo off
echo Download HCL DX container images from HCL Harbor...
echo Please enter your HCL Harbor login username/id:
set /p inputUsername=
echo Please enter your HCL Harbor CLI secrete:
set /p inputPassword=
echo Logging in into HCL Harbor...
call docker login --username %inputUsername% --password %inputPassword% https://hclcr.io/
echo Creating harbor directory, if it does not exist...
if not exist ./harbor md harbor
echo ------------------------------------------------
:: Configure here all containers that need to be pulled.
call:GetContainerFromHCLHarbor dx core DX_DOCKER_IMAGE_CORE
call:GetContainerFromHCLHarbor dx ringapi DX_DOCKER_IMAGE_RING_API
call:GetContainerFromHCLHarbor dx digital-asset-manager DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER
call:GetContainerFromHCLHarbor dx image-processor DX_DOCKER_IMAGE_IMAGE_PROCESSOR
call:GetContainerFromHCLHarbor dx content-composer DX_DOCKER_IMAGE_CONTENT_COMPOSER
call:GetContainerFromHCLHarbor dx persistence-node DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER
call:GetContainerFromHCLHarbor dx persistence-connection-pool DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER
call:GetContainerFromHCLHarbor dx haproxy DX_DOCKER_IMAGE_HAPROXY
call:GetContainerFromHCLHarbor dx prereqs-checker DX_DOCKER_IMAGE_PREREQS_CHECKER
call:setPropertiesFile 

:GetContainerFromHCLHarbor
if "%1" NEQ "" (
    if "%2" NEQ "" ( 
        if "%3" NEQ "" ( goto getFromHCLHarbor %1 %2 %3 )))
EXIT /B 0

:getFromHCLHarbor
echo Processing %1-%2 container...
echo Finding %1-%2-tags on https://hclcr.io...
curl "https://hclcr.io/api/v2.0/projects/%1/repositories/%2/artifacts?page=1&page_size=10&with_tag=true" -s -u "%inputUsername%:%inputPassword%" -H "Accept: application/json" -H "Content-type: application/json" > ./harbor/harbor_result.json
echo Extract tags using jq-windows-amd64.exe (need to be downloaded from URL https://jqlang.org/)...
jq-windows-amd64.exe -r ".[] .tags .[] .name" ./harbor/harbor_result.json > ./harbor/%1-%2-tags.txt
set "tags="
for /F "delims=" %%i in (./harbor/%1-%2-tags.txt) do if not defined tags set tags=%%i
echo Pulling images...
docker pull hclcr.io/%1/%2:%tags%
echo Pulling %1-%2 container finished.
echo Cleanup temp files...
cd harbor
del "harbor_result.json"
cd ..
echo cleanup finished.
set arg1=%3
set arg2=hclcr.io/dx/%2:%tags%
echo Set variable: %arg1%=%arg2%
set "%arg1%=%arg2%"
echo ------------------------------------------------
EXIT /B 0

:setPropertiesFile 
echo Updating properties file with image tags...
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
) ELSE IF %%m==DX_DOCKER_IMAGE_HAPROXY (
    IF %DX_DOCKER_IMAGE_HAPROXY%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_HAPROXY%)
) ELSE IF %%m==DX_DOCKER_IMAGE_PREREQS_CHECKER (
    IF %DX_DOCKER_IMAGE_PREREQS_CHECKER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_PREREQS_CHECKER%)
) else ( echo %%m)
))>result.properties
DEL dx.properties
rename result.properties dx.properties
echo Task completed.
EXIT /B 0
