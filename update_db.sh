#!/usr/bin/env bash

WAIT_LIMIT=30

function runUpdate {
    CMD="mysql -u ${MYSQL_ROOT_USERNAME} -p${MYSQL_ROOT_PASSWORD} -h 0.0.0.0 -P 3306 -N -e \"SHOW DATABASES LIKE '${MYSQL_DATABASE}';\" 2> /dev/null"

    output=""
    wait_time=0

    until (output=$(eval $CMD) && [ "$output" != "" ]) || [ $wait_time -ge $WAIT_LIMIT ]; do
       echo "Database '${MYSQL_DATABASE}' not started..."
       sleep 1
       let wait_time=wait_time+1
    done

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

