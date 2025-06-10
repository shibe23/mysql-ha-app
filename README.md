# Start container
```bash
docker-compose up -d
```

# Rebuild container

```bash
docker-compose down -v
docker-compose build
docker-compose up -d
```

# Execute MySQL

```bash
docker exec -it mysql-master mysql -uroot -prootpass
```
# List
```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \\n"SELECT * FROM app_db.users;"
```

# Log

```bash
docker logs --tail 50 --follow --timestamps mysql-master
```

# Insert test record

```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \
"INSERT INTO app_db.users (email, name) VALUES ('replica-test@example.com', 'Rep Test');"
```

# Misc
## ProxySQLのルール確認

```bash
docker exec -it proxysql mysql -uadmin -padmin -h127.0.0.1 -P6032 -e "SELECT * FROM stats_mysql_query_rules;"
```

## 認証済みプラグインの全件表示

```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \
"SELECT PLUGIN_NAME, PLUGIN_STATUS FROM information_schema.PLUGINS WHERE PLUGIN_TYPE='AUTHENTICATION';"
```

## プラグインの全件表示

```bash
docker exec -it mysql-master mysql -uroot -prootpass -e \
"SHOW PLUGINS;"
```

# api-app

## GET User

```bash
curl http://localhost:3000/users
```

# Prometheus
http://localhost:9090/ 

# Grafana
http://localhost:3001/


## POST User

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","name":"Taro"}'
```

# failback

```
docker-compose up -d mysql-master
docker exec -it mysql-client /scripts/failback.sh
```