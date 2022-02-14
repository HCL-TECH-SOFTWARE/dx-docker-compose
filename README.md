# HCL DX docker-compose

This little scripting enables you to run a fully fledged DX environment with minimal footprint on your local machine.
It uses docker-compose to start/stop and manage Docker containers.
Docker-compose an addon on top of Docker.
On Mac OS Docker desktop docker-compose is available out of the box.
On other OS, you might need to manually install docker-compose even if you have docker installed already.
For installation instructions see: <https://docs.docker.com/compose/install/>

## Setup your environment

Start by cloning this repository locally and cd into the `dx-docker-compose` directory.

All you need to do is to load the HCL DX docker images into your local docker repository and set up your local environment with some environment variables.

### Loading DX docker images

The load.sh script expects a path to a directory containing the docker image archives as a command line argument <docker-image-archives-directory>.

**Note:** If you already loaded the DX docker images into a docker repository of your choice, you may skip executing `load.sh` or `load.bat`.
Please make sure to update the image names in the `dx.properties` file appropriately.

Linux/MAC:

```bash
cd ./dx-docker-compose
bash load.sh <docker-image-archives-directory>
```

Windows:

```bash
cd ./dx-docker-compose
load.bat <docker-image-archives-directory>
```

### Set up local environment variables

Linux/MAC:

```bash
cd ./dx-docker-compose
source ./set.sh
```

Windows:

```bash
cd ./dx-docker-compose
set.bat
```

**Note:** The second command is **source ./set.sh** and not just executing set.sh directly.

If you want to unset your DX docker-compose environment, you can do so by running `unset.sh`:

Linux/MAC:

```bash
cd ./dx-docker-compose
source ./unset.sh
```

Windows:

```bash
cd ./dx-docker-compose
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

If your user does not have permission to write to the persistent volumes location (folder `dx-docker-compose/volumes`) specified in the docker-compose file dx.yaml, you will see errors and the system will not start properly. If necessary, change the permissions of this folder so that the user running the docker process can read and write to it.

Here are some useful command line arguments to run `docker-compose up`:

- `-d, --detach`: detached mode
- `--remove-orphans`: this cleans up orphaned containers
- `--scale SERVICE=NUM`: this lets you run multiple instances of a service (see further instructions below)

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

NAME                 CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
dx-ds                0.16%     73.48MiB / 31.21GiB   0.23%     171kB / 16.4MB    0B / 16.4kB       23
production_nginx     0.00%     7.008MiB / 31.21GiB   0.02%     11.1MB / 10.8MB   0B / 0B           9
dx-dam               0.27%     493.4MiB / 31.21GiB   1.54%     263MB / 381MB     8.19kB / 19.5kB   78
dx-dam-db-pool       0.05%     116.8MiB / 31.21GiB   0.37%     586MB / 659MB     0B / 1.44MB       36
dx-ringapi           0.17%     104.2MiB / 31.21GiB   0.33%     1.45MB / 1.2MB    0B / 24.1kB       23
dx-dam-db-node-0     0.07%     63.26MiB / 31.21GiB   0.20%     414MB / 233MB     0B / 15.6MB       14
dx-core              0.80%     2.137GiB / 31.21GiB   6.85%     1.62MB / 6.71MB   436MB / 563MB     375
dx-cc                0.19%     71.73MiB / 31.21GiB   0.22%     7.7kB / 0B        0B / 11.3kB       23
dx-image-processor   0.17%     426.3MiB / 31.21GiB   1.33%     17.5MB / 4.27MB   0B / 23kB         23

```

To get an overview of running docker-compose services, you can run

```bash
docker-compose ps
```

Example output:

```bash
IMAGE                                                      COMMAND                  CREATED      STATUS                PORTS                                                                                                                                                                                                                                                                                                                                                                                                                      NAMES
hcl/dx/design-studio:v0.6.0_20211213-1448                  "/opt/app/start_all_…"   3 days ago   Up 3 days             0.0.0.0:5500->3000/tcp, :::5500->3000/tcp                                                                                                                                                                                                                                                                                                                                                                                  dx-ds
nginx:latest                                               "/docker-entrypoint.…"   3 days ago   Up 3 days             0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp                                                                                                                                                                                                                                                                                                                                                   production_nginx
hcl/dx/digital-asset-manager:v1.12.0_20211213-1448         "/opt/app/start_all_…"   3 days ago   Up 3 days             0.0.0.0:3000->3001/tcp, :::3000->3001/tcp                                                                                                                                                                                                                                                                                                                                                                                  dx-dam
hcl/dx/persistence-connection-pool:v1.13.0_20211213-1457   "/scripts/entrypoint…"   3 days ago   Up 3 days (healthy)   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                                                                                                                                                                                                                                                                                                                                                                                  dx-dam-db-pool
hcl/dx/ringapi:v1.13.0_20211213-1457                       "/opt/app/start_all_…"   3 days ago   Up 3 days             0.0.0.0:4000->3000/tcp, :::4000->3000/tcp                                                                                                                                                                                                                                                                                                                                                                                  dx-ringapi
hcl/dx/persistence-node:v1.3_20211213-1454                 "/start_postgres.sh"     3 days ago   Up 3 days (healthy)   0.0.0.0:5433->5432/tcp, :::5433->5432/tcp                                                                                                                                                                                                                                                                                                                                                                                  dx-dam-db-node-0
hcl/dx/core:v95_CF200_20211213-1442                        "sh -c /opt/app/entr…"   3 days ago   Up 3 days             0.0.0.0:7777->7777/tcp, :::7777->7777/tcp, 0.0.0.0:10020->10020/tcp, :::10020->10020/tcp, 10032/tcp, 0.0.0.0:10033->10033/tcp, :::10033->10033/tcp, 10034-10038/tcp, 0.0.0.0:10039->10039/tcp, :::10039->10039/tcp, 10040/tcp, 0.0.0.0:10041->10041/tcp, :::10041->10041/tcp, 10042/tcp, 0.0.0.0:10200->10200/tcp, :::10200->10200/tcp, 0.0.0.0:10202-10203->10202-10203/tcp, :::10202-10203->10202-10203/tcp, 10201/tcp   dx-core
hcl/dx/content-composer:v1.13.0_20211213-1443              "/opt/app/start_all_…"   3 days ago   Up 3 days             0.0.0.0:5000->3000/tcp, :::5000->3000/tcp                                                                                                                                                                                                                                                                                                                                                                                  dx-cc
hcl/dx/image-processor:v1.13.0_20211213-1446               "/home/dx_user/start…"   3 days ago   Up 3 days             0.0.0.0:3500->8080/tcp, :::3500->8080/tcp                                                                                                                                                                                                                                                                                                                                                                                  dx-image-processor

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
  #   - dx-core
```

2. Update the `PORTAL_HOST` parameter values.

```yaml
environment:
  - PORTAL_HOST=example.com
```

The result of the changes to the `ringapi` service should look similar to the snippet below:

```yaml
ringapi:
  # depends_on:
  #   - dx-core
  image: ${DX_DOCKER_IMAGE_RINGAPI:?'Missing docker image environment parameter'}
  environment:
    - DEBUG=ringapi-server:*
    - PORTAL_PORT=10039
    - PORTAL_HOST=example.com
  ports:
    - "4000:3000"
  networks:
    - default
```

Update the Content Composer service configuration as described:

```yaml
environment:
  - PORTAL_HOST=example.com
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
cd ./dx-docker-compose
source ./installApps.sh
```

Windows:

```bash
cd ./dx-docker-compose
installApps.bat
```

### Connecting to your DX and applications.

To access your dx environment, navigate to _http://<PORTAL_HOST>/wps/portal_

Example: http://example.com/wps/portal

To access dx admin console, navigate to _https://<PORTAL_HOST>:10041/ibm/console_

Example: https://example.com:10041/ibm/console

To access the ConfigWizard Server Admin console _https://<PORTAL_HOST>:10203/ibm/console_

Example: https://example.com:10203/ibm/console

### Connecting into a docker-compose service via bash

To bash into a docker container of a service, you can directly connect using the service name

```bash
docker-compose exec dam bash
```

To connect into a specific container of a service (if there is multiple containers running for a service), you have to look up the name of the container e.g. using `docker-compose ps` and then run

```bash
docker exec -it dx_dam bash
```
