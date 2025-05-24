FROM mysql:8.4

COPY setup/replica-init.sh /docker-entrypoint-initdb.d/replica-init.sh
RUN chmod +x /docker-entrypoint-initdb.d/replica-init.sh
