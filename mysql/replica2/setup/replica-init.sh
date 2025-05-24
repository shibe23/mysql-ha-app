#!/bin/bash

echo "[INFO] Waiting for MySQL master to be ready..."

# 60回 (最大約2分) 試行
for i in {1..60}; do
  if mysql -h mysql-master -uroot -prootpass -e "SELECT 1" >/dev/null 2>&1; then
    echo "[INFO] MySQL master is available."
    break
  fi
  echo "[INFO] Waiting ($i)..."
  sleep 2
done

if [ $i -eq 60 ]; then
  echo "[ERROR] MySQL master did not become available in time."
  exit 1
fi

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
