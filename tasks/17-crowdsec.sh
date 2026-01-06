#!/bin/bash
# Instalovat CrowdSec, collections a bouncer.

log "Přidávám apt repozitář a spouštím aktualizaci repozitářů..."
mkdir -p /etc/apt/keyrings/
curl -fsSL https://packagecloud.io/crowdsec/crowdsec/gpgkey \
| gpg --dearmor -o /usr/share/keyrings/crowdsec-archive-keyring.gpg

tee /etc/apt/sources.list.d/crowdsec_crowdsec.list > /dev/null <<'EOF'
deb [signed-by=/usr/share/keyrings/crowdsec-archive-keyring.gpg] https://packagecloud.io/crowdsec/crowdsec/any any main
deb-src [signed-by=/usr/share/keyrings/crowdsec-archive-keyring.gpg] https://packagecloud.io/crowdsec/crowdsec/any any main
EOF

apt-get update

sleep 2

log "Instaluji Crowdsec a nastavuji automatické spouštění..."
apt_install crowdsec
systemctl enable crowdsec

log "Doinstalovávám collections..."
cscli collections install crowdsecurity/linux
cscli collections install crowdsecurity/iptables
cscli collections install crowdsecurity/base-http-scenarios
cscli collections install crowdsecurity/http-cve
cscli collections install crowdsecurity/nginx-proxy-manager
cscli collections install crowdsecurity/home-assistant
cscli collections install crowdsecurity/wordpress
cscli collections install gauth-fr/immich
cscli collections install MariuszKociubinski/bitwarden
cscli collections install a1ad/meshcentral
cscli collections install MrShippeR/filebrowser
cscli collections install LePresidente/jellyfin

log "Doinstalovávám firewall bouncer..."
apt_install crowdsec-firewall-bouncer-iptables

crowdsec -t && systemctl restart crowdsec

log "Varování - je nutno nastavit cesty k logům, které se mají skenovat přes krok 18) ve skriptu."

log "Nezapomenout Enroll security engine with https://app.crowdsec.net/security-engines."
sleep 3
