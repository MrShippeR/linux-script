#!/bin/bash

# Program pro lehčí uživatelské zadání stahování do programu ulozto-downloader
# verze 1.0
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

printf "${orange}Započítávám stahování souboru z ulož.to do složky $home_path ${no_color}"
sleep $sleep_time
echo

ulozto-downloader --parts 15 --output $home_path --auto-captcha $url