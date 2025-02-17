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

The load.sh script expects a path to a directory containing the docker image archives as a command line argument.

**_NOTE:_** If you already loaded the DX docker images into a docker repository of your choice, you may skip executing `load.sh` or `load.bat`.
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

If the docker compose is not running on local, then DX_HOSTNAME value in set.sh/set.bat needs to be modified accordingly.

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

> **_NOTE:_** The second command is **source ./set.sh** and not just executing set.sh directly.

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

## Starting the environment

After setting your environment, you can start the DX docker-compose environment by running. **Important** is that you need to be using a minimum version `1.27.4` for `docker-compose`.

```bash
docker-compose up
```

This will start all services defined in `dx.yaml` and logs will be printed directly go to your bash.
You can stop docker-compose in this situation by pressing `CTRL+C`.

If your user does not have permission to write to the persistent volumes location (folder `dx-docker-compose/volumes`) specified in the docker-compose file dx.yaml, you will see errors and the system will not start properly. If necessary, change the permissions of this folder so that the user running the docker process can read from and write to it.

Here are some useful command line arguments to run `docker-compose up`:

- `-d, --detach`: detached mode
- `--remove-orphans`: this cleans up orphaned containers

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
dx-haproxy           1.46%     30.3MiB / 11.67GiB    0.25%     73.6kB / 136kB    0B / 8.19kB       8
dx-peopleservice     0.00%     131.5MiB / 11.67GiB   1.10%     436kB / 655kB     0B / 12.1MB       24
dx-cc                1.59%     147.6MiB / 11.67GiB   1.24%     408kB / 70.4kB    51.7MB / 8.19kB   23
dx-dam               5.54%     589.4MiB / 11.67GiB   4.93%     1.65MB / 1.49MB   26.1MB / 8.19kB   78
dx-ringapi           1.45%     174.5MiB / 11.67GiB   1.46%     416kB / 2.15MB    56.3MB / 8.19kB   23
dx-dam-db-pool       53.55%    335MiB / 11.67GiB     2.80%     2.66MB / 3.14MB   12.7MB / 1.78MB   38
dx-prereqs-checker   4.12%     23.98MiB / 11.67GiB   0.20%     4.65kB / 0B       11.5MB / 4.1kB    11
dx-image-processor   1.31%     201.4MiB / 11.67GiB   1.69%     419kB / 79.4kB    86.8MB / 8.19kB   23
dx-core              330.29%   1.744GiB / 11.67GiB   14.94%    113kB / 66.6kB    393MB / 253MB     315
dx-dam-db-node-0     34.21%    388.4MiB / 11.67GiB   3.25%     1.79MB / 1.19MB   6.26MB / 160kB    48

```

To get an overview of running docker-compose services, you can run

```bash
docker-compose ps
```

Example output:

```bash
IMAGE                                                           COMMAND                  CREATED          STATUS                    PORTS                                                                                                                                                                                                                                                         NAMES
hclcr.io/dx/haproxy:v1.20.0_20241210-2256                       "/bin/bash entrypoin…"   5 minutes ago    Up 4 minutes              0.0.0.0:80->8081/tcp                                                                                                                                                                                                                                          dx-haproxy
hclcr.io/dx/people-service:v1.0.0_20241210-2231                 "/home/dx_user/entry…"   8 minutes ago    Up 8 minutes              3000/tcp, 0.0.0.0:7001->7001/tcp                                                                                                                                                                                                                              dx-peopleservice
hclcr.io/dx/content-composer:v1.37.0_20241210-2230              "/opt/app/start_all_…"   17 minutes ago   Up 17 minutes             0.0.0.0:5001->3000/tcp                                                                                                                                                                                                                                        dx-cc
hclcr.io/dx/digital-asset-manager:v1.36.0_20241210-2303         "/opt/app/start_all_…"   20 minutes ago   Up 17 minutes             0.0.0.0:3000->3001/tcp                                                                                                                                                                                                                                        dx-dam
hclcr.io/dx/ringapi:v1.37.0_20241210-2252                       "/opt/app/start_all_…"   20 minutes ago   Up 17 minutes             0.0.0.0:4000->3000/tcp                                                                                                                                                                                                                                        dx-ringapi
hclcr.io/dx/persistence-connection-pool:v1.34.0_20241210-2254   "/scripts/entrypoint…"   20 minutes ago   Up 17 minutes (healthy)   0.0.0.0:5432->5432/tcp                                                                                                                                                                                                                                        dx-dam-db-pool
hclcr.io/dx/prereqs-checker:v1.0.0_20241210-2243                "/bin/bash set_cronj…"   20 minutes ago   Up 20 minutes             0.0.0.0:81->8082/tcp                                                                                                                                                                                                                                          dx-prereqs-checker
hclcr.io/dx/image-processor:v1.37.0_20241210-2258               "/home/dx_user/start…"   20 minutes ago   Up 20 minutes             0.0.0.0:3500->8080/tcp                                                                                                                                                                                                                                        dx-image-processor
hclcr.io/dx/core:v95_CF224_20241210-2319                        "sh -c /opt/app/entr…"   20 minutes ago   Up 20 minutes             0.0.0.0:7777->7777/tcp, 0.0.0.0:10020->10020/tcp, 10032/tcp, 0.0.0.0:10033->10033/tcp, 10034-10038/tcp, 0.0.0.0:10039->10039/tcp, 10040/tcp, 0.0.0.0:10041->10041/tcp, 10042/tcp, 0.0.0.0:10200->10200/tcp, 0.0.0.0:10202-10203->10202-10203/tcp, 10201/tcp   dx-core
hclcr.io/dx/persistence-node:v1.24_20241210-2252                "/start_postgres.sh"     20 minutes ago   Up 17 minutes (healthy)   0.0.0.0:5433->5432/tcp                                                                                                                                                                                                                                        dx-dam-db-node-0

```

## Tips and tricks

### Performance Tuning

The performance for local docker volumes on some operating systems like Mac OS and Windows is quite slow.
To improve especially the startup time of DX Core, you may choose to remove the persistent volume configuration.
To do so, remove the following lines from the docker-compose file:

```bash
    volumes:
      - ./volumes/core/wp_profile:/opt/HCL/wp_profile
```

> **_NOTE:_** When removing the volumes at all, any change you apply in DX Core will not be persisted. All your changes will be lost as soon as the container is stopped. If you need any specific folders or files been persistent, then please try to reduce it as much as possible. For example by just saving the server config of the WebSphere_Portal JVM to your local volume.  

### Debugging WebSphere_Portal JVM on dx-core container

It is possible to enable debugging mode on the WebSphere_Portal JVM to monitor/debug the whole server process.  
For that, please make sure to enable port 7777 for the core service and in your firewall. Below you will find an example to expose that port 7777 in the dx.yaml file:  

```bash  
    services:  
      core:  
        container_name: dx-core  
        image: ${DX_DOCKER_IMAGE_CORE:?'Missing docker image environment parameter'}  
        ports:  
          - "7777:7777"  
```

In addition to that it is needed to enable the WebSphere Application Server **debugging services** in the IBM Integrated Solutions Console (admin console). For details, please check: [Debugging Service details](https://www.ibm.com/docs/en/was/9.0.5?topic=applications-debugging-service-details)

> **_NOTE:_** Make sure that the changes are persistent for the current dx-core container. A WebSphere_Portal server restart is needed, as soon as the debugging services are enabled!  

After debugging is enabled you can use any IDE like Microsoft Visual Studio Code, Eclipse or IBM Rational Application Developer to connect to that remote debugging port. For details, please check: [HDX-DEV-300 HCL Digital Experience for Developers (Advanced)](https://hclsoftwareu.hcltechsw.com/courses/course/hdx-dev-300-dx-developer-advanced)  

### Adding Shared Libraries

HCL highly recommends to add shared libraries in the folder `/opt/HCL/wp_profile/PortalServer/sharedLibrary/` of the dx-core container to avoid performance problems with shared libraries.  

### Docker-compose services and load balancing

The core of a docker-compose environment are its services.
In the case of DX, each of the different DX components (Core, CC, DAM, ...) is a individual docker-compose service.
The services are all described and configured in `dx.yaml`.
Amongst other configurations, each service has a external port defined.

Inside a docker-compose environment all containers of a particular service are reachable via their service name.
If you connect into a docker container running in docker-compose, you'll be able to resolve the service name via dns. You could do so by just pinging the image processor (service name "image-processor") from any other container.
See below on how to bash into a docker-compose container.

### Running DX docker-compose in a hybrid setup

In the case that you already have a fully configured DX Core (e.g. an on premise installation) up and running, you can choose to configure docker-compose to connect to the on premise environment.
The below mentioned changes in `dx.yaml` need to be applied to make this work.

> **_NOTE:_** You will also have to configure your DX Core environment to connect to the services running docker-compose (e.g. configuration of DAM and Content Composer portlets). Please have a look in the official HCL DX Help Center to understand which changes need to be done, if necessary.

Update the Ring API service configuration as described:

1. Disable the `depends_on` parameter.

    ```yaml
    ringapi:
      # depends_on:
      #   - core
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

> **_NOTE:_** For any change in DX_HOSTNAME it's a must to re-execute installApps.sh / installApps.bat

### Connecting to your DX and applications

To access your dx environment, navigate to _http://<PORTAL_HOST>/wps/portal_

Example: `http://example.com/wps/portal`

To access dx admin console, navigate to _https://<PORTAL_HOST>:10041/ibm/console_

Example: `https://example.com:10041/ibm/console`

To access the ConfigWizard Server Admin console _https://<PORTAL_HOST>:10203/ibm/console_

Example: `https://example.com:10203/ibm/console`

### Connecting into a docker-compose service via bash

To bash into a docker container of a service, you can directly connect using the service name

```bash
docker-compose exec dam bash
```

To connect into a specific container of a service (if there is multiple containers running for a service), you have to look up the name of the container e.g. using `docker-compose ps` and then run

```bash
docker exec -it dx_dam bash
```

### Running Prerequisite Checks to your DX and applications

To perform checks to the mounted volumes, you can directly connect using the dx-prereqs-checker container

```bash
docker-compose exec prereqs-checker /bin/bash /usr/local/sbin/run_test.sh
```

To display the logs of the check results, run

```bash
docker-compose logs prereqs-checker
```

### DX Development with Visual Studio Code & Docker-Compose  

Please check the course content:  
[HDX-DEV-300 HCL Digital Experience for Developers (Advanced)](https://hclsoftwareu.hcltechsw.com/courses/course/hdx-dev-300-dx-developer-advanced)  

### Best practice  

- Always use `docker-compose up` command to start your environment
- Make sure that the installApps.sh / installApps.bat script is already completed, before accessing the environment.
  Only then the additional extentions like Content Composer and DAM will be available!
- Try to avoid using volumes (at best don't use volumes at all to get the best speed)
- Avoid restarting the dx-core container for performance reasons (If needed, just stop/start the server directly in the dx-core container)
- Add shared libraries into folder `/opt/HCL/wp_profile/PortalServer/sharedLibrary/` of the dx-core container
- In the Web-Browser:  
  - Access your Portal environment with URL: `http://<hostname>/wps/portal`.  
  - Don't access the portal over the direct port! (for example: `http://localhost:10039/wps/portal`). If you do so, then you might not be able to access addons like the Content Composer or DAM. The whole communication works via the embeded http-proxy!  
  - By default accessing the portal server environment via https is not configured out of the box. Additional steps need to be done to enable SSL.

## Enabling Secured Socket Layer (SSL )

### Prerequisites

OpenSSL need to be installed, if own self-signed certificates will be used.
Installation instructions can be found at [Install openSSL](https://github.com/openssl/openssl/blob/master/INSTALL.md#installing-openssl).  

> **_NOTE:_**  
The **ssl** folder contains a localhost.pem file that can be used with the haproxy service running on a local environment. The certificate is created for the hostname localhost and it never expires. Please modify the create_certificates scripts for your needs, if you want to use your own certificates.

### Instructions

1. Create own self signed certificates  
   Navigate to the **ssl** folder and execute the create_certificates script  

    Windows:  

    ```bash
        create_certificates.bat  
    ```

    Linux/Mac:

    ```bash
        ./create_certificates.sh  
    ```

2. Change the haproxy.cfg file in the following section:

      ```yaml
        frontend dx
          bind :8081

          use_backend dam if { path -m reg ^/dx/(api|ui)/dam/ }
          use_backend content if { path_beg /dx/ui/content/ }
          use_backend image-processor if { path_beg /dx/api/image-processor/ }
          use_backend ring-api if { path_beg /dx/api/core/ }

          default_backend core-dx-home

        backend core-dx-home
          server core dx-core:10039 check resolvers nameserver init-addr none
      ```  

   to use:

      ```yaml
        frontend dx  
          #BIND SSL and HTTP PORT
          bind :8083 ssl crt /etc/ssl/private/localhost.pem  
          bind :8081

          use_backend dam if { path -m reg ^/dx/(api|ui)/dam/ }
          use_backend content if { path_beg /dx/ui/content/ }
          use_backend image-processor if { path_beg /dx/api/image-processor/ }
          use_backend ring-api if { path_beg /dx/api/core/ }

          #DEFAULT BACKEND CONNECTS OVER HTTPS
          default_backend core-dx-home-ssl

        backend core-dx-home
          server core dx-core:10039 check resolvers nameserver init-addr none


        backend core-dx-home-ssl 
          server core dx-core:10041 check resolvers nameserver init-addr none ssl verify none
      ```

3. Modify the dx.yaml and change the haproxy service from:

   ```yaml
   haproxy:
     image: ${DX_DOCKER_IMAGE_HAPROXY:?'Missing docker image environment parameter'}
     container_name: dx-haproxy
     volumes:
       - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
     ports:
       - 80:8081
     networks:
       - default
   ```

    to:  

    ```yaml
    haproxy:
      image: ${DX_DOCKER_IMAGE_HAPROXY:?'Missing docker image environment parameter'}
      container_name: dx-haproxy
      volumes:
        - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
        - ./ssl/localhost.pem:/etc/ssl/private/localhost.pem      
      ports:
        - 80:8081
        - 443:8083
      networks:
        - default        
      ```

4. Run `docker-compose up` to start the environment

5. Install or update CC, DAM and DXConnect applications in DX Core to use SSL

      Linux/MAC:

      ```bash
      ./installApps_SSL_Enabled.sh
      ```

      Windows:

      ```bash
      installApps_SSL_Enabled.bat
      ```

6. Restart the dx-core container  
