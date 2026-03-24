#!/bin/bash

# Copyright 2021, 2023 HCL Technologies
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

function updateProperties () 
{
    searchValue=$1
    replaceValue="$1=$arg2"
    pathValue=$3
    strSearchAndReplace="s/${searchValue}.*/${replaceValue//\//\\/}/"
    sed -i.bck "${strSearchAndReplace}" ${pathValue}/dx.properties
} 

function getFromHCLHarbor () {
echo Processing $1-$2 container...
echo Finding $1-$2-tags on https://hclcr.io...
curl "https://hclcr.io/api/v2.0/projects/$1/repositories/$2/artifacts?page=1&page_size=10&with_tag=true" -s -u "$inputUsername:$inputPassword" -H "Accept: application/json" -H "Content-type: application/json" > ./harbor/harbor_result.json
echo "Extract tags using jq (need to be downloaded from URL https://jqlang.org/)..."
jq -r ".[] .tags .[] .name" ./harbor/harbor_result.json > ./harbor/$1-$2-tags.txt
tags=$(head -n 1 ./harbor/$1-$2-tags.txt)
echo Pulling images...
echo "docker pull hclcr.io/$1/$2:$tags"
docker pull hclcr.io/$1/$2:$tags
echo Pulling $1-$2 container finished.
echo Cleanup temp files...
rm ./harbor/harbor_result.json
echo cleanup finished.
arg1=$3
arg2="hclcr.io/dx/$2:$tags"
echo Updating the dx.properties...
updateProperties $3 $arg1 .
echo ------------------------------------------------
}

echo Download HCL DX container images from HCL Harbor...
read -p "Please enter your HCL Harbor login username/id: " inputUsername
read -s -p "Please enter your HCL Harbor CLI secrete: " inputPassword
echo Logging in into HCL Harbor...
docker login --username $inputUsername --password $inputPassword hclcr.io
echo Creating harbor directory, if it does not exist...
if [ ! -d "./harbor" ]; then  
  mkdir harbor
fi

getFromHCLHarbor dx core DX_DOCKER_IMAGE_CORE
getFromHCLHarbor dx ringapi DX_DOCKER_IMAGE_RING_API
getFromHCLHarbor dx digital-asset-manager DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER
getFromHCLHarbor dx image-processor DX_DOCKER_IMAGE_IMAGE_PROCESSOR
getFromHCLHarbor dx content-composer DX_DOCKER_IMAGE_CONTENT_COMPOSER
getFromHCLHarbor dx persistence-node DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER
getFromHCLHarbor dx persistence-connection-pool DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER
getFromHCLHarbor dx haproxy DX_DOCKER_IMAGE_HAPROXY
getFromHCLHarbor dx prereqs-checker DX_DOCKER_IMAGE_PREREQS_CHECKER
echo Task completed.
