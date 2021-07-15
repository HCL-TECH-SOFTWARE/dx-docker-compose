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

# This script will load all DX docker images that are accessible 
# through docker-compose into the local docker registry.
# In addition to that, the dx.properties file will be updated
# with the tags of the docker images that were loaded by the script.

# Function call to Replace the contents in the properties file
# $1 is the Search Value or the Key
# $2 is the Replace Value
# $3 is the Current working Directory
function updateProperties () 
{
    searchValue=$1
    replaceValue="$1=$2"
    pathValue=$3
    strSearchAndReplace="s/${searchValue}.*/${replaceValue//\//\\/}/"
    sed -i '' ${strSearchAndReplace} ${pathValue}/dx.properties
}

CWD="$PWD"


# Begins

# Pass the file path of the docker images through command line argument
filePath=$1

if [[ -d ${filePath} ]]
then
    cd ${filePath}
else
    echo "ERROR: No such directory exists. Please try again."
    exit
fi


# Declaring array of Images

listOfImages=()
listOfImages+=("DX_DOCKER_IMAGE_CONTENT_COMPOSER:hcl-dx-content-composer-image")
listOfImages+=("DX_DOCKER_IMAGE_IMAGE_PROCESSOR:hcl-dx-image-processor")
listOfImages+=("DX_DOCKER_IMAGE_DATABASE_DIGITAL_ASSET_MANAGER:hcl-dx-postgres")
listOfImages+=("DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER:hcl-dx-digital-asset-manager")
listOfImages+=("DX_DOCKER_IMAGE_RING_API:hcl-dx-ringapi")
listOfImages+=("DX_DOCKER_IMAGE_CORE:hcl-dx-core")

# Loop through the array to upload the docker image and update the properties file

listLength=${#listOfImages[@]}
for((i=0;i<${listLength};i++));
do
    listElement=${listOfImages[$i]}
    imageElement=(${listElement//:/ })
    if [ -f ${imageElement[1]}*.tar.gz ]
    then
        dockerResult=$(docker load -i ${imageElement[1]}*.tar.gz)
        echo ${dockerResult}
        loadCheck=${dockerResult:0:12}
        imageName=${dockerResult:13}
        if [ "$loadCheck" == "Loaded image" ]; then
            updateProperties ${imageElement[0]} ${imageName} ${CWD}
        else
            echo "Error occured while loading " ${imageElement[1]}*.tar.gz "file into docker"
        fi
    else
        echo "WARNING:" ${imageElement[1]}*.tar.gz "File is not available in the provided path"
    fi
done
echo "Property file updated with image tags"

cd $CWD
echo "Task completed"
