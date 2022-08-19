#!/bin/bash

# version 1.5 from 21-12-01
# version 1.6 from 22-01-28 - adding function to set input comma separated
# autor marek@vach.cz

# initial variables #
menu=(
"0) přeji si udělat všechny následující kroky"
"1) instalovat gnome-tweaks pro nastavení klikání pravým tlačítkem touchpadu"
"2) sjednotit zápis času pro skoky mezi Windows a Linux"
"3) instalovat prohlížeč Brave"
"4) instalovat Seafile client"
"5) instalovat Screen"
"6) instalovat Discord"
"7) instalovat Signal"
"8) instalovat Docker a Docker-Container"
"9) instalovat driver tiskárny Samsung M2020"
"10) instalovat KolourPaint"
"11) instalovat net-tools"
"12) instalovat TeamViewer"
"13) instalovat ulozto-downloader"
"14) instalovat yourube-dl")
menu+=([100]="100) ukončit skript")

highest_menu_number=$(echo $((${#menu[@]} - 2))) # count of array minus 0 and 100
blue='\033[0;34m'
green='\033[0;32m'
orange='\033[0;33m'
red='\033[0;31m'
no_color='\033[0m'
sleep_time=0.8

# define functions and install instructions #
do_switch_case() {
	printf "${orange}Aktualizace repozitářů $choice:${no_color}"
	sudo snap refresh
	sudo apt-get update
	
	printf "${orange}Započínám vykonávání úkoly $choice:${no_color}"
	sleep $sleep_time
	case $choice in

		1)
			sudo apt-get install gnome-tweaks -y
			echo "Otevírám gnome-tweaks v samostatném procesu."
 		 	gnome-tweaks &  # & starts separate process
		;;

		2)		
			sudo timedatectl set-local-rtc 1 --adjust-system-clock
		;;

		3)
			sudo apt install apt-transport-https curl
			sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
			echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
			sudo apt update
			sudo apt install brave-browser
		;;

		4)	
			sudo apt-get install seafile-gui -y	
		;;

		5)
			sudo apt-get install screen -y
		;;

		6)
			sudo snap install discord
		;;

		7)
			sudo snap install signal-desktop
		;;

		8)
			echo "Instalace potřebných podprogramů a přidání repozitáře..."
			sleep $sleep_time
			
			sudo apt-get install \
    				ca-certificates \
    				curl \
    				gnupg \
    				lsb-release
			curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			
			echo \
                              "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                               $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

			echo "Instalace docker engine..."
			sleep $sleep_time
			sudo apt-get update
			sudo apt-get install docker-ce docker-ce-cli containerd.io -y
			docker version

			echo "Instalace docker-compose..."
			sleep $sleep_time
			sudo apt-get install docker-compose -y
			docker compose version

			echo "Nastavení automatického spuštění a přidání uživatele do skupiny docker"
			sleep $sleep_time
			sudo groupadd docker
			sudo usermod -aG docker $USER	
			echo "Pro aktivaci oprávnění je potřeba restartovat PC..."	

			sudo systemctl enable docker.service	
			sudo systemctl enable containerd.service
		;;

		9)			
			file_name=uld_V1.00.39_01.17.tar.gz
			cd ~/Stažené	
			
			if test -f "$file_name"; then
				echo ""				
				echo "Soubor již stažený je, přeskakuji krok..."
			else
				wget https://ftp.ext.hp.com/pub/softlib/software13/printers/SS/SL-C4010ND/$file_name
			fi

			if test -d "uld"; then
				echo "Extrahovaná složka již existuje, přeskakuji extrakci..."
			else
				tar xvf $file_name
			fi

			cd uld/
			printf "${red}Zmáčknout Enter, Q, pro přeskočení skrolování. ${no_color}"
			sleep 3
			echo ""
			sudo ./install.sh
		;;

		10)
			sudo snap install kolourpaint
		;;

		11)
			sudo apt-get install net-tools -y
			echo ""
			echo "Otestování nástroje PING:"
			ping -c 2 google.com
			echo ""
			ping -c 2 vach.cz
		;;

		12)
			cd ~/Stažené
			wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
			sudo dpkg -i teamviewer_amd64.deb		
		;;
		
		13)
			cd ~/Stažené
			echo "Instaluji balíky potřebné pro běh aplikace ulozto-downloader: python3-pip, tor, python3-tflite-runtime"
			sleep $sleep_time
			
			sudo apt install python3-pip -y
			sudo apt install tor -y
			
			echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
			curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
			sudo apt-get update
			sudo apt-get install python3-tflite-runtime -y
			sudo apt-get install python3-tk -y
			
			echo "Instaluji ulozto-downloader"
			sleep $sleep_time
			sudo pip3 install --upgrade ulozto-downloader

			echo "Instaluji zjednodušení pro zadávání příkazu do Terminálu"
			sleep $sleep_time
			cd "/usr/local/bin/"
			sudo wget https://raw.githubusercontent.com/MrShippeR/linux-script/main/ulozto.sh
			sudo mv ulozto.sh ulozto
			sudo chmod a+rx ulozto
			sudo chown root:root ulozto
			
			# printf "${orange}Příklad příkazu pro stahování: ulozto-downloader --auto-captcha --parts 15 'https://ulozto.cz/file/TKvQVDFBEhtL/debian-9-6-0-amd64-netinst-iso'${no_color}"
			echo
			printf "${orange}Příklad příkazu pro stahování: ulozto 'https://ulozto.cz/file/TKvQVDFBEhtL/debian-9-6-0-amd64-netinst-iso'${no_color}"
		;;

		14)
			echo "Instaluji program pro stahování videí youtube-dl..."
			sleep $sleep_time
			# https://github.com/ytdl-org/youtube-dl
			sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
			sudo chmod a+rx /usr/local/bin/youtube-dl

			echo
			echo "Instaluji závislosti - Python..."
			sleep $sleep_time
			sudo apt install python3 -y
			sudo apt install python-is-python3 -y

			printf "${orange}Příkaz zadávat ve tvaru: youtube-dl [OPTIONS] URL [URL...]${no_color}"

		;;

		100)
			exit	
		;;

	esac
	echo ""
	printf "${green}Úloha ${menu[$choice]} dokončena.${no_color}"
	echo ""
	((choice++))
	sleep $sleep_time
}
######

# Main function - user input and program logic #

echo ""
echo "Skript pro rychlou instalaci 2021 Marek@Vach.cz v1.6"
echo ""
printf '%s\n' "${menu[@]}"
echo ""

read -p "Vícenásobné zadání oddělujte čárkami. Vyberte akci, kterou chcete od programu vykonat: " choice;

# check input for comma separated values and then explode (or just create) array from values
if [[ $choice == *","* ]]
then
  choices=($(echo $choice | tr "," "\n"))
  echo "Byly zvoleny úlohy:"
else
  choices=($choice)
  echo "Byla zvolena úloha:"
fi

# foreach function to print choices on script start execution
for choice in "${choices[@]}"
do
   echo "${menu[$choice]}"
done

echo "###################################"
sleep $sleep_time

# foreach function to execute tasks
for choice in "${choices[@]}"
do
   if [ $choice -eq 0 ]
   then
	for ((choice = 1; choice <= $highest_menu_number; choice++)); 
	do
  	   do_switch_case
	done
	break # allow just one execution of do all tasks
   else
        do_switch_case
   fi
done
echo "Skript doběhl do konce. Esc..."
