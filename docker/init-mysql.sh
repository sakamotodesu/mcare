#!/bin/sh
#docker-compose exec db bash -c "chmod 0775 docker-entrypoint-initdb.d/init-database.sh"
#docker-compose exec db bash -c "./docker-entrypoint-initdb.d/init-database.sh"
mysql --defaults-extra-file=~/.mysql/mysql.conf -h 127.0.0.1 mcare < "./db/sql/001-create-tables.sql"