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

:: This script installs CC and DAM portlets into DX Core running in a docker-compose environment


echo "##########################################################################"
echo "Installing CC, DS and DAM portlets using DX_HOSTNAME=%DX_HOSTNAME%
echo "##########################################################################"
echo ""
docker-compose exec core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh enable-headless-content -DWasPassword=wpsadmin -DPortalAdminPwd=wpsadmin -Dstatic.ui.url=http://%DX_HOSTNAME%:5000/dx/ui/content/static"
docker-compose exec core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh enable-media-library -DWasPassword=wpsadmin -DPortalAdminPwd=wpsadmin -DdigitalAssets.baseUrl=http://%DX_HOSTNAME%:3000 -DdigitalAssets.uiSuffix=/::/home/media?hcldam=true -Dexperience.api.url=http://%DX_HOSTNAME%:4000/dx/api/core/v0 -Dstatic.ui.url=http://%DX_HOSTNAME%:3000/dx/ui/dam/static"
docker-compose exec core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh enable-content-sites -DWasPassword=wpsadmin -DPortalAdminPwd=wpsadmin -Dcontentsites.static.ui.url=http://%DX_HOSTNAME%:5500/dx/ui/site-manager/static"
echo ""
echo "#########################################################################"
echo "Installed CC, DS and DAM portlets using DX_HOSTNAME=%DX_HOSTNAME%
echo "#########################################################################"
echo ""
echo "###############################################################"
echo "Install DXConnect Application and restart config wizard server"
echo "###############################################################"
docker-compose exec core sh -c "/opt/HCL/wp_profile/ConfigEngine/./ConfigEngine.sh reinstall-dxconnect-application"
docker-compose exec core sh -c "/opt/HCL/AppServer/profiles/cw_profile/./startServer.sh server1"
echo "##################################################################"
echo "Installed DXConnect Application and restarted config wizard server"
echo "##################################################################"
