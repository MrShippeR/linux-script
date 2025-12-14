#!/bin/bash
# Aktivovat Wake on LAN
NETWORK_INTERFACE="Drátové připojení 1"

log "Zobrazuji info o rozhraní před změnou: $NETWORK_INTERFACE"
nmcli connection show $NETWORK_INTERFACE | grep 802-3-ethernet.wake-on-lan:
nmcli connection show $NETWORK_INTERFACE | grep 802-3-ethernet.auto-negotiate:

nmcli connection modify $NETWORK_INTERFACE 802-3-ethernet.wake-on-lan magic
nmcli connection modify $NETWORK_INTERFACE 802-3-ethernet.auto-negotiate yes

log "Zobrazuji info o rozhraní po změně: $NETWORK_INTERFACE"
nmcli connection show $NETWORK_INTERFACE | grep 802-3-ethernet.wake-on-lan:
nmcli connection show $NETWORK_INTERFACE | grep 802-3-ethernet.auto-negotiate:
