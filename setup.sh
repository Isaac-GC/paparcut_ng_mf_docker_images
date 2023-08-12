#!/usr/share/env bash

## Setup Prerequisites
apt update 
apt install -y --no-install-recommends wget cpio cups ca-certificates python3 python3-pip

pip install requests

useradd -mUd /papercut -s /bin/bash papercut
echo "papercut - nofile 65535" >> /etc/security/limits.conf

# Get and Setup Papercut NG/MF
wget https://cdn1.papercut.com/web/products/ng-mf/installers/mf/${PAPERCUT_MAJOR_VER}/pcmf-setup-${PAPERCUT_VERSION}.sh -O pcmf-setup.sh
chmod a+rx pcmf-setup.sh 

runuser -l papercut -c "/pcmf-setup.sh -v --non-interactive" 
rm -f pcmf-setup.sh

/papercut/MUST-RUN-AS-ROOT
/etc/init.d/papercut stop
/etc/init.d/papercut-web-print stop

# Setup Mysql 
wget ${MYSQL_CONNECTOR_DOWNLOAD_URL} -O mysql.tar.gz
tar -xzvf mysql.tar.gz -C / 
rm mysql.tar.gz 
mv /mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar /papercut/server/lib-ext/ 
rm -r /papercut/mysql-connector-java-${MYSQL_CONNECTOR_VERSION} 

# Finish Setting up Papercut NG/MF 
chown -R papercut:papercut /papercut 
chmod +x /papercut/server/bin/linux-x64/setperms 
/papercut/server/bin/linux-x64/setperms 
apt-get clean autoclean 
apt-get autoremove -y 
rm -rf /var/lib/{apt,dpkg,cache,log}/ 
runuser -l papercut -c "/papercut/server/bin/linux-x64/db-tools init-db -f -q"


# Finish setting up image with default/presets
/etc/init.d/papercut start
/etc/init.d/papercut-web-print start

python3 /app/image_setup.sh

/etc/init.d/papercut stop
/etc/init.d/papercut-web-print stop