#!/bin/bash
# Instalovat docker-log-linker a stáhnout CrowdSec acquis.d složku z Gitu

PATH_TMP_DLL="/tmp/docker-log-linker-install"
URL_GITHUB_DLL="https://raw.githubusercontent.com/MrShippeR/docker-log-linker/refs/heads/main/release/latest/docker-log-linker.deb"
FILENAME_DLL="docker-log-linker.deb"

PATH_CROWDSEC_ACQUIS="/etc/crowdsec/acquis.d"
PATH_TMP_ACQUIS="/tmp/acquis-github"
GITHUB_ACQUIS_URL="https://github.com/MrShippeR/my-crowdsec-acquis.d.git"
GITHUB_ACQUIS_NAME="my-crowdsec-acquis.d"



log "Stahuji $FILENAME_DLL z Githubu do složky v TMP..."
mkdir -p $PATH_TMP_DLL
wget -P $PATH_TMP_DLL $URL_GITHUB_DLL

log "Instaluji balíček $FILENAME_DLL"
dpkg -i $PATH_TMP_DLL/$FILENAME_DLL

if dpkg -s docker-log-linker >/dev/null 2>&1; then
	log "Nainstalováno. Volání je pomocí sudo systemctl start docker-log-linker.service"
	log "Odstraňuji stažený balíček ze složky TMP."
	rm -r $PATH_TMP_DLL
else
    log "Chyba. Instalace balíčku $FILENAME_DLL se nezdařila! Skript končí."
    exit 1
fi

sleep 2



log "Vytvářím složku $PATH_CROWDSEC_ACQUIS"
mkdir -p $PATH_CROWDSEC_ACQUIS

log "Stahuji repozitář $GITHUB_ACQUIS_NAME z Githubu..."
mkdir -p $PATH_TMP_ACQUIS
git clone $GITHUB_ACQUIS_URL $PATH_TMP_ACQUIS

if ! compgen -G "$PATH_TMP_ACQUIS/*.yaml" > /dev/null; then
	log "Chyba. Ve složce nebyly nalezeny žádné .yaml soubory, takže stažení repozitáře $GITHUB_ACQUIS_NAME se nezdařilo. Skript končí."
	exit 1
fi

log "Stažení úspěšné. Přesouvám stažené konfiguráky do složky s CrowdSec, duplicity přeskakuji..."
cp --update=none $PATH_TMP_ACQUIS/*.yaml $PATH_CROWDSEC_ACQUIS/

log "Odstraňuji dočasnou složku v TMP..."
rm -r $PATH_TMP_ACQUIS

log "Spouštím CrowdSec kontrolu syntaxe a restartuji CrowdSec..."
crowdsec -t && systemctl restart crowdsec

log "Varování. Nezapomenout nastavit správně docker-log-linker ve složce etc. Aby stažené yaml soubory mířily na funkční log soubory."
sleep 3

