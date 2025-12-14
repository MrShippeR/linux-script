#!/bin/bash
# Instalovat unattended-upgrades.

apt_install unattended-upgrades

log "Vkládám hodnoty do konfiguračního souboru /etc/apt/apt.conf.d/20auto-upgrades"
echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
