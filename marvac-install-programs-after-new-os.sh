#!/bin/bash

# initial variables #
menu=(
"0) přeji si udělat všechny následující kroky"
"1) instalovat gnome-tweaks pro nastavení klikání pravým tlačítkem touchpadu"
"2) sjednotit zápis času pro skoky mezi Windows a Linux"
"3) instalovat prohlížeč Brave"
"4) instalovat Nextcloud"
"5) instalovat Screen"
"6) instalovat Discord"
"7) instalovat Signal"
"8) instalovat Docker a Docker-Container"
"9) instalovat driver tiskárny Samsung M2020"
"10) instalovat KolorPaint"
"11) instalovat net-tools"
"12) instalovat TeamViewer")
menu+=([100]="100) ukončit skript")

highest_menu_number=$(echo $((${#menu[@]} - 2))) # count of array minus 0 and 100
do_all_tasks=false
blue='\033[0;34m'
orange='\033[0;33m'
no_color='\033[0m'
sleep_time=0.8

# define functions #
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
			
		;;

		5)
			sudo apt-get install screen
		;;

		6)
			
		;;

		7)
			
		;;

		8)
			
		;;

		9)
			
		;;

		10)
			
		;;

		11)
			
		;;

		12)
			
		;;

		100)
			exit	
		;;

	esac
	echo ""
	printf "${blue}Úloha ${menu[$choice]} dokončena.${no_color}"
	echo ""
	((choice++))
	sleep $sleep_time
}
######

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


