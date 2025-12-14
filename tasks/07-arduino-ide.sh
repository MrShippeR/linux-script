#!/bin/bash
# Instalovat Arduino IDE 2.3.6
ARDUINO_DIR="/home/SYSTEM_USER/Arduino"

expect <<'EOF'
spawn add-apt-repository universe
expect "Stiskněte*ENTER*"
send "\r"
expect eof
EOF

apt_install libfuse2

mkdir -p $ARDUINO_DIR
cd $ARDUINO_DIR

wget https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.6_Linux_64bit.AppImage
chown $SYSTEM_USER:$SYSTEM_USER arduino-ide_2.3.6_Linux_64bit.AppImage
chmod +x arduino-ide_2.3.6_Linux_64bit.AppImage

wget https://github.com/arduino/ArduinoCore-mbed/blob/main/post_install.sh
chown $SYSTEM_USER:$SYSTEM_USER post_install.sh
chmod +x post_install.sh
source post_install.sh

echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", GROUP="plugdev", MODE="0666"' | tee /etc/udev/rules.d/99-arduino.rules > /dev/null

usermod -a -G dialout $SYSTEM_USER
log "Restart system is needed to permissions for Arduino IDE take effect."

