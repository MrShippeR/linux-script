#!/bin/bash
# Instalovat Wireguard GUI.
WG_FILE_NAME="wireguird_amd64.deb"

cd $TMP_DIR
apt_install wireguard-tools
wget https://github.com/UnnoTed/wireguird/releases/download/v1.1.0/$WG_FILE_NAME
chmod $SYSTEM_USER:$SYSTEM_USER $WG_FILE_NAME
dpkg -i $WG_FILE_NAME

log "Odstraňuji instalační soubor $WG_FILE_NAME"
rm $TMP_DIR/$WG_FILE_NAME

