#!/usr/bin/env bash

function runUpdate {
    sleep 10

    liquibase --classpath=/opt/liquibase/lib/snakeyaml-1.17.jar \
              --classpath=/opt/jdbc/mysql-jdbc.jar \
              --changeLogFile=/opt/changelog/${LIQUIBASE_CHANGELOG} \
              --url=jdbc:mysql://localhost/${MYSQL_DATABASE}?nullNamePatternMatchesAll=true \
              --username=${MYSQL_ROOT_USERNAME} \
              --password=${MYSQL_ROOT_PASSWORD} \
              --logLevel=${LIQUIBASE_LOGLEVEL} \
              update \
              ${LIQUIBASE_EXTRA_PROPERTIES}

}

runUpdate &

/usr/local/bin/docker-entrypoint.sh "$@"

