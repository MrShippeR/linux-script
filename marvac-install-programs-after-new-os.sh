#!/bin/bash

# version 1.5 from 21-12-01
# version 1.6 from 22-01-28 - adding function to set input comma separated
# version 1.7 from 23-04-18 - adding wsdd for network visibility on windows machines
# version 1.8 from 24.05.30 - adding vlc and changing apt-update to run only once during loop; adding -y for apt-install; remove ulozto-downloader and yourube-dl
# version 1.9 from 24-06-20 - adding programs for server installation
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
"8) instalovat Docker a Docker-Compose"
"9) instalovat Podman a Podman-Compose"
"10) instalovat driver tiskárny Samsung M2020"
"11) instalovat KolourPaint"
"12) instalovat net-tools"
"13) instalovat VLC player"
"14) viditelnost ostatním (Windows) počítačům"
"15) vytvořit zástupce bash-skripty"
"16) instalovat Cockpit"
"17) nastaví UFW defaultní pravidla, vypne IPV6, povolí rozsah LAN sítě"
"18) instalovat unattended-upgrades a vyvolat konfiguraci programu"
"19) instalovat snapshot zálohu systému Timeshift"
"20) upravit nastavení sítě v /etc/sysctl.conf , set unpriviliged port 80 and enable port forwarding"
"21) instalovat Crowdsec pro Ubuntu 22.04 LTS"
"22) Přepnout z Wayland na X11"
"23) instalovat NPM z nodejs.org")
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
			sudo apt install -y apt-transport-https curl
			sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
			echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
			sudo apt update -y
			sudo apt install -y brave-browser
		;;

		4)	
			sudo apt-get install -y seafile-gui
		;;

		5)
			sudo apt-get install -y screen
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
			
			sudo apt-get install -y \
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
			sudo apt-get update -y
			sudo apt-get install -y docker-ce docker-ce-cli containerd.io
			docker version

			echo "Instalace docker-compose..."
			sleep $sleep_time
			sudo apt-get install -y docker-compose
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
                        sudo apt-get install -y podman
                        sudo apt-get install -y podman-docker
                        sudo systemctl enable podman
                        podman --version

                        echo "Instaluji Python3 pro stažení dodatečného pluginu podman-compose"
                        sudo apt-get install -y python3
                        sudo apt-get install -y python3-pip

                        pip3 install https://github.com/containers/podman-compose/archive/main.tar.gz
                        echo -e "\nexport PATH=\$PATH:\$HOME/.local/bin" >> ~/.bashrc

                        # https://bugs.launchpad.net/ubuntu/+source/libpod/+bug/2024394
                        echo "Opravuji bug plugin bridge does not support config version 1.0.0 ..."
                        sleep 1
                        sudo mkdir -p /tmp/podman-installation
                        sudo chown -R 1000:1000 /tmp/podman-instalation
                        cd /etc/podman-instalation
                        curl -O http://archive.ubuntu.com/ubuntu/pool/universe/g/golang-github-containernetworking-plugins/containernetworking-plugins_1.1.1+ds1-3build1_amd64.deb
                        sudo dpkg -i containernetworking-plugins_1.1.1+ds1-3build1_amd64.deb

                        echo "Vytvářím síť 'optiplex' pro Nginx-proxy-manager"
                        podman network create optiplex

                        echo "Nastavuji rootless přístup k podman"
                        sudo apt-get install -y slirp4netns
                ;;

		10)			
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

		11)
			sudo snap install kolourpaint
		;;

		12)
			sudo apt-get install -y net-tools
			echo ""
			echo "Otestování nástroje PING:"
			ping -c 2 google.com
			echo ""
			ping -c 2 vach.cz
		;;
		
		13)
			echo "Instaluji VLC player"
                        sleep $sleep_time

                        sudo apt install -y vlc
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
			sudo apt install -y python3
			sudo apt install -y python-is-python3

			printf "${orange}Příkaz zadávat ve tvaru: youtube-dl [OPTIONS] URL [URL...]${no_color}"

		;;

                15)
                       echo "Vytvářím zástupce v domovské složce pro bash-skripty"
                       ln -s /usr/local/bin/ ~/bash-skripty

                ;;

                16)
                       sudo mkdir -p /tmp/cockpit-files-install
                       sudo chown -R 1000:1000 /tmp/cockpit-files-install
                       cd /tmp/cockpit-files-install

                       sudo apt-get install -y cockpit cockpit-storaged cockpit-networkmanager cockpit-packagekit cockpit-machines cockpit-podman cockpit-sosreport

                       curl -LO https://github.com/45Drives/cockpit-file-sharing/releases/download/v3.3.7/cockpit-file-sharing_3.3.7-1focal_all.deb
                       sudo apt-get install -y ./cockpit-file-sharing_3.3.7-1focal_all.deb

                       sudo apt-get install -y gettext nodejs npm make
                       git clone https://github.com/cockpit-project/cockpit-files.git
                       cd cockpit-files
                       sudo make

                       wget https://github.com/ocristopfer/cockpit-sensors/releases/latest/download/cockpit-sensors.tar.xz && \
                       tar -xf cockpit-sensors.tar.xz cockpit-sensors/dist && \
                       sudo mv cockpit-sensors/dist /usr/share/cockpit/sensors && \
                       rm -r cockpit-sensors && \
                       rm cockpit-sensors.tar.xz

                       sudo systemctl enable --now cockpit.socket
                       echo "Cockpit je dostupný na adrese https://localhost:9090"
                ;;

                17)
                       echo
                       sudo sed -i 's/^IPV6=yes/IPV6=no/' /etc/default/ufw && echo "Změna v konfiguračním souboru /etc/defaults/ufw úspěšná." || echo "Parametr IPV6 v /etc/defaults/ufw nenalezen, ponecháno beze změny."
                       echo
                       sudo ufw reload
                       sleep 1

                       sudo ufw default deny incoming
                       sudo ufw default allow outgoing
                       sudo ufw allow from 192.168.0.0/24 comment "LAN allowed"
                       sudo ufw enable
                       sudo ufw status numbered
                ;;

                18)
                       sudo apt-get install -y unattended-upgrades
                       sudo dpkg-reconfigure -plow unattended-upgrades
                ;;

                19)
                       sudo add-apt-repository -y ppa:teejee2008/ppa
                       sudo apt-get update
                       sudo apt-get install -y timeshift
                ;;

                20)
                       sudo sh -c 'echo "" >> /etc/sysctl.conf && echo "net.ipv4.ip_unprivileged_port_start=80" >> /etc/sysctl.conf'
                       sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
                       # sudo sysctl --system
                       sudo sysctl -p
                ;;

                21)
                       sudo apt-get install -y debian-archive-keyring
                       sudo apt-get install -y curl gnupg apt-transport-https

                       sudo mkdir -p /etc/apt/keyrings/
                       wget -qO- https://packagecloud.io/crowdsec/crowdsec/gpgkey | gpg --dearmor | sudo tee /etc/apt/keyrings/crowdsec_crowdsec-archive-keyring.gpg >/dev/null

                       sudo touch /etc/apt/sources.list.d/crowdsec_crowdsec.list
                       sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/crowdsec_crowdsec-archive-keyring.gpg] https://packagecloud.io/crowdsec/crowdsec/ubuntu jammy main" >> /etc/apt/sources.list.d/crowdsec_crowdsec.list'
                       sudo sh -c 'echo "deb-src [signed-by=/etc/apt/keyrings/crowdsec_crowdsec-archive-keyring.gpg] https://packagecloud.io/crowdsec/crowdsec/ubuntu jammy main"  >> /etc/apt/sources.list.d/crowdsec_crowdsec.list'

                       sudo apt-get update
                       sudo apt-get install -y crowdsec
                       sudo apt-get install -y crowdsec-firewall-bouncer-iptables # You need to deploy a bouncer to apply decisions.

                       sudo systemctl status crowdsec
                       sudo systemctl enable crowdsec

                       sudo cscli collections install crowdsecurity/iptables

                       sudo cscli parsers install crowdsecurity/whitelists
                       sudo mkdir -p /etc/crowdsec/parsers/s02-enrich
                       # následující příkaz musí být odřádkovaný formátem, mezerami pro použití v souboru .yml
                       sudo tee -a /etc/crowdsec/parsers/s02-enrich/mywhitelist.yaml <<EOF
name: my/whitelists
description: "MyWhitelist"
whitelist:
  reason: "Home IP range whitelisted"
  ip:
    - "172.18.0.10"      # Wireguard VPN
    - "94.113.162.202"   # Brno IP
  cidr:
    - "192.168.0.0/24"
EOF


                       sudo cscli collections install crowdsecurity/nginx-proxy-manager
                       # následující příkaz musí být odřádkovaný formátem, mezerami pro použití v souboru .yml
                       sudo tee -a /etc/crowdsec/acquis.yaml <<EOF
# manually added nginx-proxy-manager
filenames:
  - /home/shipper/podman/nginx-proxy-manager/data/logs/*.log
labels:
  type: nginx-proxy-manager
---
EOF

                       sudo systemctl reload crowdsec
                       echo
                       echo "Nezapomenout!!! Enroll security engine with https://app.crowdsec.net/security-engines"
                       sleep 3
                       echo
                ;;

                22)
                       sudo sed -i -e '/^#WaylandEnable=false/s/^#//' /etc/gdm3/custom.conf && grep -q '^WaylandEnable=false' /etc/gdm3/custom.conf && echo "Řádek v konfiguráku nalezen. Pro aplikování změny je nutno restartovat počítač." || echo "Chyba. Textový řetězec 'WaylandEnable=false' v souboru /etc/gdm3/custom.conf nebyl nalezen."
                ;;

                23)
                       echo "Odinstalovávám předinstalované nodejs a npm."
                       sleep 3
                       sudo apt-get remove -y nodejs npm

                       sudo apt-get install -y python3 g++ make python3-pip
                       sudo apt-get install -y ca-certificates curl gnupg
                       sudo mkdir -p /etc/apt/keyrings
                       curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

                       NODE_MAJOR=20
                       echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

                       sudo apt-get update
                       sudo apt-get install -y nodejs
                       sudo apt-get install -y build-essential

                       node --version
                       npm --version
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
echo "Skript pro rychlou instalaci 2021 Marek@Vach.cz v1.9"
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

printf "${orange}Aktualizace repozitářů $choice:${no_color}"
sudo snap refresh
sudo apt-get update -y

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
