#!/bin/bash

# Program pro lehčí uživatelské zadání stahování do programu ulozto-downloader
# verze 1.1
# 02. 07. 2022 Přidána možnost vybrat si cílovou destinaci ke stažení souboru plus počet vláken ke stahování.
# 27. 11. 2021 marek@vach.cz

# Instalace - v terminálu zadat $PATH
# Zkopírovat skript do složky a odstranit koncovku .sh, tedy jen ulozto
# Nastavit oprávnění pro spouštění příkazu: chmod +x ulozto

if [[ $# -eq 0 ]] ; then
    echo "Příkaz je potřeba zadávat ve tvaru: ulozto 'https://uloz.to/file/xXYxa'"
    exit 0
fi

orange='\033[0;33m'
no_color='\033[0m'
sleep_time=2

url=$1
home_path="/home/$USER/Stažené/"
CURRENT_PATH=$(pwd)

echo "Do jakého adresáře se má soubor stáhnout?"
echo "[0] současný adresář: ${CURRENT_PATH}"
echo "[1] Stažené soubory:  ${home_path}"
read -p "0/1: " choice;

if [[ "$choice" == 1 ]]
then
   path=$home_path
else
   path=$CURRENT_PATH
fi
echo "Soubor bude stažen do složky $path"
echo ""

read -p "Na kolik částí soubor rozdělit [def. 15]: " parts;

if [[ "$parts" -ge 1 ]] && [[ "$parts" -le 100 ]]
then
   :
else
   parts=15
   echo "Nastavena defaultní hodnota: $parts částí"
fi

printf "${orange}Započítávám stahování souboru z ulož.to do složky $path přes $parts vláken. ${no_color}"
sleep $sleep_time
ulozto-downloader --parts $parts --output $path --auto-captcha $url
