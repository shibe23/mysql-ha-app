#!/bin/bash

# 新しいMaster（現在のmaster）と旧Master（復帰対象）
NEW_MASTER="mysql-replica1"
OLD_MASTER="mysql-master"
MYSQL_USER="root"
MYSQL_PASS="rootpass"
PROXYSQL_HOST="proxysql"
PROXYSQL_PORT="6032"
PROXYSQL_USER="radminuser"
PROXYSQL_PASS="radminpass"

echo "[INFO] Checking if old master is back online..."
if ! mysqladmin -h "$OLD_MASTER" -u"$MYSQL_USER" -p"$MYSQL_PASS" ping >/dev/null 2>&1; then
  echo "[FAIL] Old master not reachable: $OLD_MASTER"
  exit 1
fi

echo "[INFO] Configuring old master as replica of new master..."

mysql -h "$OLD_MASTER" -u"$MYSQL_USER" -p"$MYSQL_PASS" -e "
  STOP REPLICA;
  RESET REPLICA ALL;
  SET GLOBAL read_only = ON;
  CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='$NEW_MASTER',
    SOURCE_USER='repl',
    SOURCE_PASSWORD='replpass',
    SOURCE_AUTO_POSITION=1;
  START REPLICA;
"

echo "[PROXYSQL] Updating mysql_servers to demote $OLD_MASTER to hostgroup 20..."

mysql -h "$PROXYSQL_HOST" -P "$PROXYSQL_PORT" -u"$PROXYSQL_USER" -p"$PROXYSQL_PASS" -e "
  UPDATE mysql_servers SET hostgroup_id=20 WHERE hostname = '$OLD_MASTER';
  LOAD MYSQL SERVERS TO RUNTIME;
  SAVE MYSQL SERVERS TO DISK;
"

echo "[DONE] $OLD_MASTER is now a replica of $NEW_MASTER"
