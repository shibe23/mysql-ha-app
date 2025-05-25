# Start container
```
docker-compose up -d
```

# Execute mysql
```
docker exec -it mysql-master mysql -uroot -prootpass
```

# Log

```
docker logs --tail 50 --follow --timestamps mysql-master
```

# Insert test record

```
docker exec -it mysql-master mysql -uroot -prootpass -e \
"INSERT INTO app_db.users (email, name) VALUES ('replica-test@example.com', 'Rep Test');"
```

# Misc

## 認証済みプラグインの全件表示

```
docker exec -it mysql-master mysql -uroot -prootpass -e \
"SELECT PLUGIN_NAME, PLUGIN_STATUS FROM information_schema.PLUGINS WHERE PLUGIN_TYPE='AUTHENTICATION';"
```

## プラグインの全件表示

```
docker exec -it mysql-master mysql -uroot -prootpass -e \
"SHOW PLUGINS;"
```