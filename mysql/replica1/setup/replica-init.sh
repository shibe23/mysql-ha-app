#!/bin/bash

# 60回 (最大約2分) 試行
echo "[INFO] Waiting for MySQL master to be ready..."
until mysql -h mysql-master -uroot -prootpass -e "SELECT 1"; do
  sleep 2
done

echo "[INFO] Configuring replication..."
mysql -uroot -prootpass -e "
  CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='mysql-master',
    SOURCE_USER='repl',
    SOURCE_PASSWORD='replpass',
    SOURCE_AUTO_POSITION=1;
  START REPLICA;
"

echo "[INFO] Replica setup complete."
