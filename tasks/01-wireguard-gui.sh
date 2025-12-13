#!/bin/bash
# Instalovat Wireguard GUI.

cd $TMP_DIR
apt_install wireguard-tools
wget https://github.com/UnnoTed/wireguird/releases/download/v1.1.0/wireguird_amd64.deb
dpkg -i wireguird_amd64.deb

