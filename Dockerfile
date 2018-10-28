FROM mysql:5.7.22

# Download Java
# Reused from https://github.com/docker-library/openjdk/blob/master/8/jre/slim/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
	&& rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

# do some fancy footwork to create a JAVA_HOME that's cross-architecture-safe
RUN ln -svT "/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)" /docker-java-home
ENV JAVA_HOME /docker-java-home/jre

ENV JAVA_VERSION 8u181
ENV JAVA_DEBIAN_VERSION 8u181-b13-2~deb9u1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20170531+nmu1

RUN set -ex; \
	\
# deal with slim variants not having man page directories (which causes "update-alternatives" to fail)
	if [ ! -d /usr/share/man/man1 ]; then \
		mkdir -p /usr/share/man/man1; \
	fi; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
		ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
# verify that "docker-java-home" returns what we expect
	[ "$(readlink -f "$JAVA_HOME")" = "$(docker-java-home)" ]; \
	\
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
	update-alternatives --query java | grep -q 'Status: manual'

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Below is based off https://github.com/kilna/liquibase-mysql-docker

ARG liquibase_version=3.5.5
ARG liquibase_download_url=https://github.com/liquibase/liquibase/releases/download/liquibase-parent-${liquibase_version}

RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/*\
    && tarfile=liquibase-${liquibase_version}-bin.tar.gz\
    && mkdir /opt/liquibase\
    && cd /opt/liquibase\
    && wget ${liquibase_download_url}/${tarfile}\
    && tar -xzf ${tarfile}\
    && chmod +x liquibase\
    && ln -s /opt/liquibase/liquibase /usr/local/bin/liquibase\
    && rm ${tarfile}


# Download Liquibase MySQL driver
ARG jdbc_driver_version=8.0.11
ARG jdbc_driver_download_url=https://dev.mysql.com/get/Downloads/Connector-J/

RUN mkdir /opt/jdbc\
    && cd /opt/jdbc\
    && tarfile=mysql-connector-java-${jdbc_driver_version}.tar.gz\
    && wget ${jdbc_driver_download_url}/${tarfile}\
    && tar -x -f ${tarfile}\
    && jarfile=mysql-connector-java-${jdbc_driver_version}.jar\
    && mv mysql-connector-java-${jdbc_driver_version}/$jarfile .\
    && rm ${tarfile}\
    && rm -R mysql-connector-java-${jdbc_driver_version}\
    && ln -s ${jarfile} mysql-jdbc.jar

ENV LIQUIBASE_LOGLEVEL ${LIQUIBASE_LOGLEVEL:-debug}

# Install the script to start database and run liquibase update command
ADD update_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/update_db.sh

# Database arguments
ENV MYSQL_DATABASE ${MYSQL_DATABASE:-db}
ENV MYSQL_ROOT_USERNAME ${MYSQL_ROOT_USERNAME:-root}
ENV MYSQL_ROOT_PASSWORD ${MYSQL_ROOT_PASSWORD:-root}

# Liquibase arguments
ENV LIQUIBASE_CHANGELOG ${LIQUIBASE_CHANGELOG:-changelog.xml}
ENV LIQUIBASE_EXTRA_PROPERTIES ${LIQUIBASE_EXTRA_PROPERTIES:-""}

# Create directory changelog into image
VOLUME /opt/changelog

ENTRYPOINT ["update_db.sh"]
CMD ["mysqld"]