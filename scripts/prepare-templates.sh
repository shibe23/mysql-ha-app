#!/bin/bash
set -e

echo "[INFO] Generating files from templates..."

# プロジェクトルートにある .env を読み込む
if [ ! -f .env ]; then
  echo "[ERROR] .env file not found!"
  exit 1
fi

# 環境変数を読み込み
set -a
source .env
set +a

# init.sql の生成
envsubst < mysql/init/init.sql.template > mysql/init/init.sql
echo "[OK] Generated mysql-master/init/init.sql"

# proxysql.cnf の生成
envsubst < proxysql/proxysql.cnf.template > proxysql/proxysql.cnf
echo "[OK] Generated proxysql/proxysql.cnf"

echo "[DONE] Template preparation complete."
