#!/bin/bash

echo "[INFO] Waiting for MySQL master to be ready..."
until mysql -h mysql-master -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1"; do
  sleep 2
done

echo "[INFO] Configuring replication..."
mysql -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "
  CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='mysql-master',
    SOURCE_USER='$MYSQL_REPL_USER',
    SOURCE_PASSWORD='$MYSQL_REPL_PASSWORD',
    SOURCE_AUTO_POSITION=1;
  START REPLICA;
"

echo "[INFO] Replica setup complete."
