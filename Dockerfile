FROM ubuntu:22.04

ARG PAPERCUT_MAJOR_VER=21.x
ARG PAPERCUT_VERSION=21.0.4.57587

ARG MYSQL_CONNECTOR_VERSION=8.0.30
ARG MYSQL_CONNECTOR_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz

# WORKDIR /papercut

RUN apt update; apt install -y --no-install-recommends wget cpio cups ca-certificates ;\
    useradd -mUd /papercut -s /bin/bash papercut; \
    echo "papercut - nofile 65535" >> /etc/security/limits.conf; \
    wget https://cdn1.papercut.com/web/products/ng-mf/installers/mf/${PAPERCUT_MAJOR_VER}/pcmf-setup-${PAPERCUT_VERSION}.sh -O pcmf-setup.sh; \
    chmod a+rx pcmf-setup.sh ; \
    runuser -l papercut -c "/pcmf-setup.sh -v --non-interactive" ; \
    rm -f pcmf-setup.sh ; \
    /papercut/MUST-RUN-AS-ROOT ; \
    /etc/init.d/papercut stop ;\
    /etc/init.d/papercut-web-print stop ;\
    wget ${MYSQL_CONNECTOR_DOWNLOAD_URL} -O mysql.tar.gz ;\
    tar -xzvf mysql.tar.gz -C / ;\
    rm mysql.tar.gz ;\ 
    mv /mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar /papercut/server/lib-ext/ ;\
    rm -r /papercut/mysql-connector-java-${MYSQL_CONNECTOR_VERSION} ;\
    chown -R papercut:papercut /papercut ;\
    chmod +x /papercut/server/bin/linux-x64/setperms ;\
    /papercut/server/bin/linux-x64/setperms ;\
    apt-get clean autoclean ;\
    apt-get autoremove -y ;\
    rm -rf /var/lib/{apt,dpkg,cache,log}/ ;\
    runuser -l papercut -c "/papercut/server/bin/linux-x64/db-tools init-db -f -q"


EXPOSE 9191 \
        9192 \
        9193

ENTRYPOINT [ "/etc/init.d/papercut" ]
CMD [ "console" ]