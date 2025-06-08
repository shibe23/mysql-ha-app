#!/bin/bash

# 接続情報
MYSQL_USER="root"
MYSQL_PASS="rootpass"
PROXYSQL_HOST="proxysql"
PROXYSQL_PORT="6032"
PROXYSQL_USER="radminuser"
PROXYSQL_PASS="radminpass"
REPLICAS=("mysql-replica1" "mysql-replica2")
MASTER="mysql-master"

# Masterチェック
if mysqladmin -h "$MASTER" -u"$MYSQL_USER" -p"$MYSQL_PASS" ping >/dev/null 2>&1; then
  echo "[OK] Master is alive: $MASTER"
  exit 0
fi

echo "[FAIL] Master is DOWN: $MASTER"
echo "Attempting to promote a replica..."

for REPLICA in "${REPLICAS[@]}"; do
  if mysql -h "$REPLICA" -u"$MYSQL_USER" -p"$MYSQL_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "[PROMOTE] $REPLICA is alive. Promoting..."
    mysql -h "$REPLICA" -u"$MYSQL_USER" -p"$MYSQL_PASS" -e "
      STOP REPLICA;
      RESET REPLICA ALL;
      SET GLOBAL read_only = OFF;
    "

    echo "[PROXYSQL] Updating mysql_servers..."
    mysql -h "$PROXYSQL_HOST" -P "$PROXYSQL_PORT" -u"$PROXYSQL_USER" -p"$PROXYSQL_PASS" -e "
      UPDATE mysql_servers SET hostgroup_id=20 WHERE hostgroup_id=10;
      UPDATE mysql_servers SET hostgroup_id=10 WHERE hostname = '$REPLICA';
      LOAD MYSQL SERVERS TO RUNTIME;
      SAVE MYSQL SERVERS TO DISK;
    "

    echo "[DONE] Failover complete. $REPLICA is now master."
    exit 0
  fi
done

echo "[ERROR] No available replica to promote."
exit 1
