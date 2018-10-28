mysqlVersion=5.7.22
liquibaseVersion=3.5.5

build:
	docker build -t mysql-$(mysqlVersion)-liquibase-$(liquibaseVersion) .