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

# This script installs CC, DAM and PeopleService portlets into DX Core running in a docker-compose environment

echo "#############################################################################"
echo "Installing CC, DAM and PeopleService portlets portlets using DX_HOSTNAME=$DX_HOSTNAME"
echo "#############################################################################"
echo ""
docker exec dx-core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh enable-headless-content -DWasPassword=wpsadmin -DPortalAdminPwd=wpsadmin -Dstatic.ui.url=http://$DX_HOSTNAME/dx/ui/content/static"
docker exec dx-core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh enable-media-library -DWasPassword=wpsadmin -DPortalAdminPwd=wpsadmin -DdigitalAssets.baseUrl=http://$DX_HOSTNAME -DdigitalAssets.uiSuffix=/#/home/media?hcldam=true -Dexperience.api.url=http://$DX_HOSTNAME/dx/api/core/v1 -Dstatic.ui.url=http://$DX_HOSTNAME/dx/ui/dam/static"
docker exec dx-core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh enable-people-service -DWasPassword=wpsadmin -DPortalAdminPwd=wpsadmin -Dpeopleservice.static.ui.context.url=/dx/ui/people -Dpeopleservice.api.context.url=/dx/api/people/v1"
echo ""
echo "############################################################################"
echo "Installed CC, DAM and PeopleService portlets using DX_HOSTNAME=$DX_HOSTNAME"
echo "############################################################################"
echo ""
echo "###############################################################"
echo "Install DXConnect Application and restart config wizard server"
echo "###############################################################"
docker exec dx-core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh reinstall-dxconnect-application"
docker exec dx-core sh -c "/opt/HCL/AppServer/profiles/cw_profile/bin/startServer.sh server1"
echo "##################################################################"
echo "Installed DXConnect Application and restarted config wizard server"
echo "##################################################################"
