#!/usr/bin/env bash
imageTag=greetings-sidecar

docker run \
       -e MYSQL_DATABASE=greetings \
       -e MYSQL_ROOT_USERNAME=root \
       -e MYSQL_ROOT_PASSWORD=root \
       -e LIQUIBASE_CHANGELOG=changelog-master.json \
       -e LIQUIBASE_EXTRA_PROPERTIES="-DappPassword=password" \
       --mount type=bind,source="${PWD}/changelog",target="/opt/changelog" \
       --name greetings \
       -p 3306:3306 \
       mysql-5.7.22-liquibase-3.5.5:latest
