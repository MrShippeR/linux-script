#!/bin/bash
# Instalovat Docker a Docker-compose

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			
tee /etc/apt/sources.list.d/docker.list > /dev/null <<EOF
deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable
EOF

log "Instalace Docker engine..."
apt_install docker-ce docker-ce-cli containerd.io
docker version
sleep 3

log "Instalace docker-compose..."
apt_install docker-compose
docker compose version
sleep 3

log "Vytvářím skupinu docker a přidávám uživatele $SYSTEM_USER do skupiny."
groupadd docker
usermod -aG docker $SYSTEM_USER
log "Pro aktivaci oprávnění je potřeba restartovat PC..."	

log "Nastavuji automatické spouštění containerd.service"
systemctl enable containerd.service

log "Docker nechávám na manuálním spouštění. Lze aktivovat pomocí systemctl enable docker.service a systemctl enable docker.socket"
# systemctl enable docker.service
# systemctl enable docker.socket

