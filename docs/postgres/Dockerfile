FROM postgres:17

USER root

FROM postgres:17

USER root

RUN apt-get update && \
    apt-get install -y postgresql-contrib postgis postgresql-17-postgis-3 && \
    rm -rf /var/lib/apt/lists/*

COPY init.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

EXPOSE 5432

