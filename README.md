# HCL DX docker-compose

This little scripting enables you to run a fully fledged DX environment with minimal footprint on your local machine.
It uses docker-compose to start/stop and manage Docker containers.
Docker-compose an addon on top of Docker.
On Mac OS Docker desktop docker-compose is available out of the box.
On other OS, you might need to manually install docker-compose even if you have docker installed already.
For installation instructions see: <https://docs.docker.com/compose/install/>

## Setup your environment

Start by cloning this repository locally and cd into the `local-docker-compose` directory.

All you need to do is to load the HCL DX docker images into your local docker repository and set up your local environment with some environment variables.

### Loading DX docker images

The load.sh script expects a path to a directory containing the docker image archives as a command line argument <docker-image-archives-directory>.

**Note:** If you already loaded the DX docker images into a docker repository of your choice, you may skip executing `load.sh` or `load.bat`. 
Please make sure to update the image names in the `dx.properties` file appropriately.

Linux/MAC:

```bash
cd ./local-docker-compose
sh load.sh <docker-image-archives-directory>
```

Windows:

```bash
cd ./local-docker-compose
load.bat <docker-image-archives-directory>
```

### Set up local environment variables

Linux/MAC:

```bash
cd ./local-docker-compose
source ./set.sh
```

Windows:

```bash
cd ./local-docker-compose
set.bat
```

**Note:** The second command is **source ./set.sh** and not just executing set.sh directly.

If you want to unset your DX docker-compose environment, you can do so by running `unset.sh`:

Linux/MAC:

```bash
cd ./local-docker-compose
source ./unset.sh
```

Windows:

```bash
cd ./local-docker-compose
unset.bat
```

### Performance on Mac OS/Windows

The performance for local docker volumes on Mac OS and Windows is quite slow.
To improve especially the startup time of DX Core, you may choose to remove the persistent volume configuration. 
To do so, remove the following lines from the docker-compose file:

```bash
    volumes:
      - ./volumes/core/wp_profile:/opt/HCL/wp_profile
```

**Note:** By applying the above change, your any change you do in DX Core will only be persisted in the running Docker container. Your changes will be lost as soon as the container is stopped.

## Starting the environment

After setting your environment, you can start the DX docker-compose environment by running. **Important** is that you need to be using a minimum version `1.27.4` for `docker-compose`.

```bash
docker-compose up
```

This will first of all pull all necessary docker images from artifactory (docker image versions are defined in `set.sh`.
After a successful pull, all services defined in `dx.yaml` are being started and logging will directly go to your bash.
You can stop docker-compose in this situation by pressing `CTRL+C`.

If your user does not have permission to write to the persistent volumes location (folder `local-docker-compose/volumes`) specified in the docker-compose file dx.yaml, you will see errors and the system will not start properly. If necessary, change the permissions of this folder so that the user running the docker process can read and write to it.

Here are some useful command line arguments to run `docker-compose up`:

* `-d, --detach`: detached mode
* `--remove-orphans`: this cleans up orphaned containers
* `--scale SERVICE=NUM`: this lets you run multiple instances of a service (see further instructions below)

The service configuration in `dx.yaml` supports up to 2 instances of DAM and up to 4 instances of the image processor. Upfront please adjust the ports section and set a port range for DAM and image processor inside of the `dx.yaml` file.

To run them at full scale, you would run:

```bash
docker-compose up -d --scale dam=2 --scale image-processor=4
```

For more information on startup parameters for `docker-compose up`, please see <https://docs.docker.com/compose/reference/up/>.

## Stopping the environment

If you didn't start docker-compose in detached mode, you can stop by pressing `CTRL+C`.
If you started docker-compose in detached mode, you can stop your environment by issuing

```bash
docker-compose stop
```

This will securely stop all running docker containers.
If you want to properly clean up your system and even purge stopped docker containers, you can do so by issuing

```bash
docker-compose down
```

## Looking at logs and metrics

### Logs

If you want to look at logs for all of the DX services, you can easily do so by running

```bash
docker-compose logs
```

This will show you all system out logs of all services of all running containers (might be quite a lot - see tips and tricks below).

### Metrics

You can also look at CPU, memory and network consumption using

```bash
docker stats
```

Example output:

```bash
CONTAINER ID        NAME                   CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
39de0fe58979        dx_ringapi_1           0.00%               136.8MiB / 7.778GiB   0.43%               3.91MB / 3.11MB     0B / 38.9kB         23
2aafeeb16d5d        dx_dam_2               0.07%               554.5MiB / 7.778GiB   1.74%               48.7MB / 113MB      0B / 29.7kB         78
d5191b2f2cea        dx_dam_1               0.06%               583.4MiB / 7.778GiB   1.83%               79MB / 145MB        0B / 30.7kB         78
b1e4c609c01e        dx_cc_1                0.00%               93.62MiB / 7.778GiB   0.29%               5.25kB / 0B         0B / 70.7kB         23
bfce5e09a40c        dx_image-processor_1   0.00%               460.3MiB / 7.778GiB   1.45%               55.7MB / 15.4MB     0B / 128kB          23
6ae153da18dd        dx_image-processor_3   0.00%               427.1MiB / 7.778GiB   1.34%               49.9MB / 12.8MB     0B / 95.2kB         23
46e63880a40f        dx_image-processor_4   0.00%               429.2MiB / 7.778GiB   1.35%               55.9MB / 15.3MB     0B / 111kB          23
9fcc921bb044        dx_image-processor_2   0.00%               411.4MiB / 7.778GiB   1.29%               44.1MB / 11.5MB     0B / 86kB           23
b93a7b7576cf        dx_core_1              0.34%               1.165GiB / 7.778GiB   3.75%               2.35MB / 4.04MB     0B / 85.5MB         215
b5062719048d        dx_dam-db_1            0.33%               23.58MiB / 7.778GiB   0.07%               60.3MB / 53.6MB     0B / 461MB          13
```

To get an overview of running docker-compose services, you can run

```bash
docker-compose ps
```

Example output:

```bash
Name                   Command                          State   Ports
------------------------------------------------------------------------------------------------------------------------
dx_cc_1                /opt/app/start_all_server.sh     Up      0.0.0.0:5000->3000/tcp
dx_core_1              sh -c WAS_ADMIN=${WAS_ADMI ...   Up      ..., 10038/tcp, 0.0.0.0:10039->10039/tcp, 10040/tcp, ...
dx_dam-db_1            /start_postgres.sh               Up      0.0.0.0:5432->5432/tcp
dx_dam_1               /opt/app/start_all_server.sh     Up      0.0.0.0:3000->3001/tcp
dx_dam_2               /opt/app/start_all_server.sh     Up      0.0.0.0:3001->3001/tcp
dx_image-processor_1   /home/dx_user/start_all_se ...   Up      0.0.0.0:6002->8080/tcp
dx_image-processor_2   /home/dx_user/start_all_se ...   Up      0.0.0.0:6000->8080/tcp
dx_image-processor_3   /home/dx_user/start_all_se ...   Up      0.0.0.0:6003->8080/tcp
dx_image-processor_4   /home/dx_user/start_all_se ...   Up      0.0.0.0:6001->8080/tcp
dx_ringapi_1           /opt/app/start_all_server.sh     Up      0.0.0.0:4000->3000/tcp
```

## Tips and tricks

### Docker-compose services and load balancing

The core of a docker-compose environment are its services.
In the case of DX, each of our different components of DX (Core, CC, DAM, ...) is a individual docker-compose service.
The services are all described and configured in `dx.yaml`.
Amongst other configurations, each service has a external port or a port range defined.

Inside a docker-compose environment all containers of a particular service are reachable via their service name.
If you e.g. connect into a docker container running in docker-compose, you'll be able to resolve the service name via dns.
If you e.g. connect into the DAM service and then run `ping image-processor`(note that "image-processor" is the docker-compose service name) multiple times, then this will connect you randomly to all running image processor containers.
See below on how to bash into a docker-compose container.

### Running DX docker-compose in a hybrid setup

In the case that you already have a fully configured DX Core (e.g. an on premise installation) up and running, you can choose to configure docker-compose to connect to the on premise environment. 
The below mentioned changes in `dx.yaml` need to be applied to make this work.

**Note:** You will also have to configure your DX Core environment to connect to the services running docker-compose (e.g. configuration of DAM and Content Composer portlets). Please have a look in the official HCL DX Help Center to understand which changes need to be done, if necessary.

Update the Ring API service configuration as described:
1. Disable the `depends_on` parameter.

  ```yaml
  ringapi:
    # depends_on:
    #   - core
  ```
  
2. Update the `PORTAL_HOST` and `CORS_ORIGIN` paramter's values.

  ```yaml
  environment: 
    - PORTAL_HOST=example.com
    - CORS_ORIGIN=http://example.com:10039
  ```
  
The result of the changes to the `ringapi` service should look similar to the snippet below: 

```yaml
ringapi:
  # depends_on:
  #   - core
  image: ${DX_DOCKER_IMAGE_RINGAPI:?'Missing docker image environment parameter'}
  environment: 
    - DEBUG=ringapi-server:*
    - PORTAL_PORT=10039 
    - PORTAL_HOST=example.com
    - CORS_ORIGIN=http://example.com:10039,http://${DX_HOSTNAME:?'Please set hostname'}:3000,http://${DX_HOSTNAME:?'Please set hostname'}:5000,http://${DX_HOSTNAME:?'Please set hostname'}:10039,http://${DX_HOSTNAME:?'Please set hostname'}:5500,http://${DX_HOSTNAME:?'Please set hostname'}:5501
  ports:
    - "4000:3000"
  networks:
    - default
```

Update the Content Composer service configuration as described:

```yaml
environment: 
  - PORTAL_HOST=example.com
  - CORS_ORIGIN=http://example.com:10039
```

### Starting and stopping individual services

#### Docker-compose up

`docker-compose up` allows you to start only individual services.
To only start the DAM service, you could run

```bash
docker-compose up -d dam
```

For more information see <https://docs.docker.com/compose/reference/up/>

#### Docker-compose stop

`docker-compose stop` allows you to stop only individual services.
To only stop the DAM service, you could run

```bash
docker-compose stop dam
```

For more information see <https://docs.docker.com/compose/reference/down/>

#### Docker-compose logs

To only look at logs for an individual service you can run

```bash
docker-compose logs dam
```

For more information see <https://docs.docker.com/compose/reference/logs/>

### Installing Applications CC, DAM and DXConnect in DX Core

To install CC, DAM and DXConnect applications in DX Core and to enable , you can run

Linux/MAC:

```bash
cd ./local-docker-compose
source ./installApps.sh
```

Windows:

```bash
cd ./local-docker-compose
installApps.bat
```

### Connecting into a docker-compose service via bash

To bash into a docker container of a service, you can directly connect using the service name

```bash
docker-compose exec dam bash
```

To connect into a specific container of a service (if there is multiple containers running for a service), you have to look up the name of the container e.g. using `docker-compose ps` and then run

```bash
docker exec -it dx_dam_1 bash
```
