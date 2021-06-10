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

# The script unsets environment variables to run DX in a docker-compose environment

unset COMPOSE_PROJECT_NAME
unset COMPOSE_FILE

unset DX_HOSTNAME

unset DX_DOCKER_IMAGE_CORE
unset DX_DOCKER_IMAGE_RINGAPI
unset DX_DOCKER_IMAGE_DAM
unset DX_DOCKER_IMAGE_IMAGE_PROCESSOR
unset DX_DOCKER_IMAGE_CC
unset DX_DOCKER_IMAGE_DAM_DB
