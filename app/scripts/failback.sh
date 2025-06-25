#!/bin/bash
set -e

OLD_MASTER="mysql-master"
REPLICA="mysql-replica1"

# 1. mysql-master が復旧しているか確認
if ! mysqladmin -h "$OLD_MASTER" -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" ping >/dev/null 2>&1; then
  echo "[FAIL] Old master is not reachable"
  exit 1
fi

# 2. 昇格処理
echo "[INFO] Promoting $OLD_MASTER as new master"
mysql -h "$OLD_MASTER" -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "
  SET GLOBAL read_only = OFF;
"

# 3. replica1 を新masterに再同期
echo "[INFO] Configuring $REPLICA as replica of $OLD_MASTER"

mysql -h "$REPLICA" -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "
  STOP REPLICA;
  RESET REPLICA ALL;
  SET GLOBAL read_only = ON;
  CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='$OLD_MASTER',
    SOURCE_USER='$MYSQL_REPL_USER',
    SOURCE_PASSWORD='$MYSQL_REPL_PASSWORD',
    SOURCE_AUTO_POSITION=1;
  START REPLICA;
"

# 4. ProxySQLのhostgroup更新
echo "[INFO] Updating ProxySQL hostgroups"
mysql -h proxysql -P6032 -u"$PROXYSQL_EXT_USER" -p"$PROXYSQL_EXT_PASS" -e "
  UPDATE mysql_servers SET hostgroup_id = 20 WHERE hostgroup_id = 10;
  UPDATE mysql_servers SET hostgroup_id = 10 WHERE hostname = '$OLD_MASTER';
  LOAD MYSQL SERVERS TO RUNTIME;
  SAVE MYSQL SERVERS TO DISK;
"

echo "[DONE] Failback complete. $OLD_MASTER is now master, $REPLICA is replica."
