#!/bin/bash
# Nastaví UFW defaultní pravidla a povolí rozsah sítí LAN a VPN

UFW_CONFIG="/etc/default/ufw"

log "Instaluji Uncomplicated Firewall..."
apt_install ufw

log "Deaktivuji vytváření pravidel pro IPv6..."
sed -i 's/^IPV6=yes/IPV6=no/' $UFW_CONFIG && log "Změna v konfiguračním souboru úspěšná." || log "Parametr IPV6 v $UFW_CONFIG nenalezen, ponecháno beze změny."

ufw reload
sleep 1

log "Nastavuji pravidla FireWallu..."
ufw default deny incoming
ufw default allow outgoing
ufw allow from 192.168.0.0/24 comment "LAN allowed"
ufw allow from 10.0.0.0/24 comment "Wireguard Turris VPN"

log "Zapínám FW. Zobrazuji nastavená pravidla."
ufw enable
ufw status numbered
sleep 3
