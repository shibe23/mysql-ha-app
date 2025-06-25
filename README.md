# MySQL High Availability Cluster with ProxySQL + Failover Scripts

このリポジトリは、**MySQL Master/Replica クラスタ + ProxySQL + 自動フェイルオーバースクリプト + Grafana可視化**による高可用構成の学習・検証環境です。

## ✅ 構成概要

```plaintext
               +-------------+
               |  App/API    |
               +------+------+
                      |
                via ProxySQL (6033)
                      |
              +-------+--------+
              |   ProxySQL     |
              | (6032 mgmt)    |
              +-------+--------+
                      |
        +-------------+-------------+
        |                           |
  mysql-master               mysql-replica1
  (initial master)           (can be promoted)

Monitoring via:
Prometheus + mysqld_exporter + Grafana
````

## 🧱 技術スタック

| コンポーネント        | 内容                                |
| -------------- | --------------------------------- |
| MySQL          | Master / Replica（GTID + binlog構成） |
| ProxySQL       | SQLレベルの読み書き分離と接続制御                |
| Bashスクリプト      | 自動フェイルオーバー・フェイルバック処理              |
| Prometheus     | MySQLメトリクスの収集                     |
| Grafana        | クエリ件数・遅延・接続数の可視化                  |
| Docker Compose | 構成の一括起動・検証環境構築                    |

## ⚙️ 使用方法

### 1. 起動

```bash
docker-compose up -d --build
```

起動後に以下のサービスが立ち上がります：

* `mysql-master`, `mysql-replica1`
* `proxysql`
* `mysql-client`（スクリプト実行用）
* `prometheus`, `grafana`

### 2. App API 利用方法（Express）

#### POST `/users`

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com", "name":"Test User"}'
```

#### GET `/users`

```bash
curl http://localhost:3000/users
```

### 3. 障害をシミュレーション（フェイルオーバー）

```bash
docker stop mysql-master
docker exec -it mysql-client /scripts/failover.sh
```

成功ログ例：

```
[PROMOTE] mysql-replica1 is alive. Promoting...
[PROXYSQL] Updating mysql_servers...
[DONE] Failover complete. mysql-replica1 is now master.
```

`replica1`の`hostgroup`が`master`と入れ替わり、10になっていることを確認
```bash
docker exec -it mysql-client \
  mysql -h proxysql -P6032 -uradminuser -pradminpass \
  -e "SELECT hostname, hostgroup_id FROM mysql_servers;"
```

### 4. 旧Master復旧と再同期（フェイルバック）

```bash
docker start mysql-master
docker exec -it mysql-client /scripts/failback.sh
```

### 5. モニタリング：Prometheus + Grafana

#### Prometheus

* URL: [http://localhost:9090](http://localhost:9090)
* 確認項目：`mysql_up`, `mysql_global_status_threads_connected`, etc.

#### Grafana

* URL: [http://localhost:3001](http://localhost:3001)
* Prometheus をデータソースに設定後、以下のダッシュボードをインポート：

```
Grafana.com Dashboard ID: 7362
「Percona MySQL Overview」テンプレート
```

## 📁 ディレクトリ構成

```plaintext
.
├── docker-compose.yml
├── app/
│   └── scripts/
│       ├── failover.sh
│       └── failback.sh
├── proxysql/
│   └── proxysql.cnf
└── mysql-*/conf.d/
    └── my.cnf
```

## ✅ 主な学習ポイント

* MySQL GTIDレプリケーションの構築と切替
* ProxySQL による読み書き分離の実践
* スクリプトによるフェイルオーバー/フェイルバックの自動化
* Prometheus + Grafana によるメトリクス監視と可視化

## 📝 参考資料

* [ProxySQL official documentation](https://proxysql.com/documentation/)
* [MySQL GTID replication](https://dev.mysql.com/doc/refman/8.0/en/replication-gtids.html)
* [Grafana Dashboards](https://grafana.com/grafana/dashboards/)

## コマンド一覧 (開発用)
### 再起動
```bash
docker-compose down -v
docker-compose build
docker-compose up -d
```

### SQLの実行
#### MySQLログイン
```bash
docker exec -it mysql-master mysql -uroot -prootpass
```

#### Tableの確認
```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \\n"SELECT * FROM app_db.users;"
```

#### レコードの追加
```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \
"INSERT INTO app_db.users (email, name) VALUES ('replica-test@example.com', 'Rep Test');"
```

#### プラグインの全件表示
```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \
"SHOW PLUGINS;"
```

#### 認証済みプラグインの全件表示
```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \
"SELECT PLUGIN_NAME, PLUGIN_STATUS FROM information_schema.PLUGINS WHERE PLUGIN_TYPE='AUTHENTICATION';"
```

#### ProxySQLのルール確認
```bash
docker exec -it proxysql mysql -uadmin -padmin -h127.0.0.1 -P6032 -e "SELECT * FROM stats_mysql_query_rules;"
```

#### Dockerログの表示

```bash
docker logs --tail 50 --follow --timestamps mysql-master
```