#!/bin/bash
# Instalovat ovladač tiskárny Samsung M2020

PRINTER_FILE_NAME="uld_V1.00.39_01.17.tar.gz"

cd $TMP_DIR			
if test -f "$PRINTER_FILE_NAME"; then			
	echo "Soubor $PRINTER_FILE_NAME je již stažený, přeskakuji stahování..."
else
	wget https://ftp.ext.hp.com/pub/softlib/software13/printers/SS/SL-C4010ND/$PRINTER_FILE_NAME
	chown $SYSTEM_USER:$SYSTEM_USER $PRINTER_FILE_NAME
fi

if test -d "uld"; then
	echo "Extrahovaná složka již existuje, přeskakuji extrakci..."
else
	tar xvf $PRINTER_FILE_NAME
	chown -R $SYSTEM_USER:$SYSTEM_USER uld
fi

log "Ovladač je stažený a extrahovaný. Započínám instalaci driveru tiskárny..."
cd uld/

expect <<'EOF'
spawn ./install.sh

expect "Press 'Enter' to continue or 'q' and then 'Enter' to quit"
send "\r"
sleep 0.5
send "q\r"

expect "Do you agree*"
send "y\r"
sleep 1
send "n\r"

expect eof
EOF

log "Promazávám složku $TMP_DIR"
cd $TMP_DIR
rm $PRINTER_FILE_NAME
rm -r uld

