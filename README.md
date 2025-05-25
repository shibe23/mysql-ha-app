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