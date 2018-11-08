# docker-mysql-liquibase
Create a MySql instance pre-populated by Liquibase scripts. Encouraged for development and not for production.

*Versions*
* MySQL: 5.7.22
* Liquibase: 3.5.5
* Java 8

Because this is a composite of docker images of MySql, openjdk, and kilna/liquibase-mysql-docker
* https://github.com/docker-library/openjdk/blob/master/8/jre/slim/Dockerfile
* https://github.com/kilna/liquibase-mysql-docker


## Running from command line
```bash
docker run \
       -e MYSQL_DATABASE=greetings \
       -e MYSQL_ROOT_USERNAME=root \
       -e MYSQL_ROOT_PASSWORD=root \
       -e LIQUIBASE_CHANGELOG=changelog-master.json \
       -e LIQUIBASE_EXTRA_PROPERTIES="-DappPassword=password" \
       --mount type=bind,source="${PWD}/changelog",target="/opt/changelog" \
       --name greetings \
       -p 3306:3306 \
       -d \
       mysql-5.7.22-liquibase-3.5.5:latest
```

## Running a new image

Dockerfile:
```dockerfile
FROM mysql-5.7.22-liquibase-3.5.5:latest

# Database arguments
ARG database=greetings
ARG root_username=root
ARG root_password=root

# Liquibase arguments
ARG changelog_dir=changelog
ARG changelog_master=changelog-master.json
ARG extra_props="-DappPassword=password"

# Copy changelog into image
RUN mkdir /opt/changelog
ADD ${changelog_dir} /opt/changelog/

# Set properties for running MySql and Liquibase
ENV MYSQL_DATABASE ${database}
ENV MYSQL_ROOT_USERNAME ${root_username}
ENV MYSQL_ROOT_PASSWORD ${root_password}
ENV LIQUIBASE_CHANGELOG ${changelog_master}
ENV LIQUIBASE_EXTRA_PROPERTIES ${extra_props}
```

Build and Run
```bash
docker build \
           --build-arg database=greetings \
           --build-arg root_password=root \
           --build-arg changelog_dir=changelog \
           --build-arg changelog_master=changelog-master.json \
           -t greetings .

docker run --name greetings -p 3306:3306 -d greetings
```