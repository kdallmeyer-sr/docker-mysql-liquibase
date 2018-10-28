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
ADD ${changelog_dir} /opt/changelog/

# Set properties for running MySql and Liquibase
ENV MYSQL_DATABASE ${database}
ENV MYSQL_ROOT_USERNAME ${root_username}
ENV MYSQL_ROOT_PASSWORD ${root_password}
ENV LIQUIBASE_CHANGELOG ${changelog_master}
ENV LIQUIBASE_EXTRA_PROPERTIES ${extra_props}