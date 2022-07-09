#!/bin/bash

set -e

output() {
  echo -e "\033[0;34m- ${1} \033[0m"
}
ask() {
  GC='\033[0;32m'
  NC='\033[0m'
  echo -e -n "${GC}- ${1}${NC} "
}
asknl() {
  GC='\033[0;32m'
  NC='\033[0m'
  echo -e "${GC}- ${1}${NC} "
}
error() {
  RC='\033[0;31m'
  NC='\033[0m'
  echo -e "${RC}ERROR: ${1}${NC}"
}

download() {
output "Downloading Chrome Remote Desktop..."
sudo apt-get update
if [[ $(/usr/bin/lsb_release --codename --short) == "stretch" ]] then
   sudo apt install --assume-yes libgbm1/stretch-backports
fi
mkdir /crdxcript
cd /crdxcript
curl -Lo chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt-get install --assume-yes /crdxcript/chrome-remote-desktop_current_amd64.deb
cd
output "Chrome Remote Desktop Installation Completed!"
asknl "Which Desktop GUI would you like to install?"
asknl "1]Xfce"
asknl "2]Cinnamon"
asknl "3]Gnome"
asknl "4]Gnome Classic"
asknl "5]KDE Plasma"
output "New GUIs  will come soon"
ask "Select GUI (1-5): "
read -r gui
if [[ "$gui" == 1 ]]; then
xfce4_install
elif [[ "$gui" == 2 ]]; then
cinnamon_install
elif [[ "$gui" == 3 ]]; then
gnome_install
elif [[ "$gui" == 4 ]]; then
gnomeclassic_install
elif [[ "$gui" == 5 ]]; then
kdeplasma_install
else
output "Use Valid Input (1-5)!"
