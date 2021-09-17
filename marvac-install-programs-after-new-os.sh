#!/bin/bash

# initial variables #
menu=(
"0) přeji si udělat všechny následující kroky"
"1) instalovat gnome-tweaks pro nastavení klikání pravým tlačítkem touchpadu"
"2) sjednotit zápis času pro skoky mezi Windows a Linux"
"3) instalovat prohlížeč Brave"
"4) instalovat Nextcloud client"
"5) instalovat Screen"
"6) instalovat Discord"
"7) instalovat Signal"
"8) instalovat Docker a Docker-Container"
"9) instalovat driver tiskárny Samsung M2020"
"10) instalovat KolourPaint"
"11) instalovat net-tools"
"12) instalovat TeamViewer")
menu+=([100]="100) ukončit skript")

highest_menu_number=$(echo $((${#menu[@]} - 2))) # count of array minus 0 and 100
do_all_tasks=false
blue='\033[0;34m'
green='\033[0;32m'
orange='\033[0;33m'
red='\033[0;31m'
no_color='\033[0m'
sleep_time=0.8

# define functions and install instructions #
do_switch_case() {
	printf "${orange}Započínám vykonávání úkoly $choice:${no_color}"
	sleep $sleep_time
	case $choice in

		1)
			sudo apt-get install gnome-tweaks
 			# gnome-tweaks &  # & starts separate process
		;;

		2)		
			timedatectl set-local-rtc 1 --adjust-system-clock
		;;

		3)
			sudo apt install apt-transport-https curl
			sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
			sudo echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
			sudo apt update
			sudo apt install brave-browser
		;;

		4)
			sudo apt-get install nextcloud-desktop
			
		;;

		5)
			sudo apt-get install screen
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
			
			sudo apt-get update
			sudo apt-get install \
    				apt-transport-https \
    				ca-certificates \
    				curl \
    				gnupg \
    				lsb-release
			curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			echo \
  			"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  			$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

			echo "Instalace docker engine..."
			sleep $sleep_time
			sudo apt-get update
			sudo apt-get install docker-ce docker-ce-cli containerd.io
			docker version

			echo "Instalace docker-compose..."
			sleep $sleep_time
			sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
			sudo chmod +x /usr/local/bin/docker-compose
			docker-compose --version

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
				wget https://ftp.hp.com/pub/softlib/software13/printers/SS/SL-C4010ND/$file_name
			fi

			if test -d "uld"; then
				echo "Extrahovaná složka již existuje, přeskakuji extrakci..."
			else
				tar xvf samsung-M2020-driver-linux.tar.gz
			fi

			cd uld/
			printf "${red}V EULA je 10 bodů, u bodu 9 zpomalit, pak Y, jinak skript spadne! ${no_color}"
			sleep 3
			echo ""
			sudo ./install.sh
		;;

		10)
			sudo snap install kolourpaint
		;;

		11)
			sudo apt install net-tools
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
			rm ~/Stažené/teamviewer_amd64.deb
			echo "Instalační soubor teamviewer_amd64.deb odstraněn."	
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

# Main function - user unput and program logic #

echo ""
echo "Skript pro rychlou instalaci 2021 Marek@Vach.cz v0.1"
echo ""
printf '%s\n' "${menu[@]}"
echo ""

read -p "Vyberte akci, kterou chcete od programu vykonat: " choice;
echo "Byla zvolena úloha ${menu[$choice]}"
echo "###################################"

if [ $choice -eq 0 ]
then
	do_all_tasks=true
fi

do_switch_case # 1st execution because while doesn't do first execution

while [ $do_all_tasks = "true" ] && [ $choice -lt $highest_menu_number ]
do
	do_switch_case # loop execution 
done

echo "Skript doběhl do konce. Esc..."


