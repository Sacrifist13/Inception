#!/bin/bash

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then

chown -R mysql:mysql /var/lib/mysql
mariadb-install-db --user=mysqld --basedir=/usr --datadir=/var/lib/mysql > /dev/null

cat << EOF > /tmp/init.sql
EOF
fi
