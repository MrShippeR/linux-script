#!/bin/bash
# Importovat CrowdSec acquis.d složku z Gitu

PATH_CROWDSEC_ACQUIS="/etc/crowdsec/acquis.d"
PATH_TMP_ACQUIS="/tmp/acquis-github"
GITHUB_ACQUIS_URL="https://github.com/MrShippeR/my-crowdsec-acquis.d.git"
GITHUB_ACQUIS_NAME="my-crowdsec-acquis.d"


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



