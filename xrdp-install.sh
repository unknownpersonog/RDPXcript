#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

output() {
  echo -e "\033[0;34m[CRDXcript] ${1} \033[0m"
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
output "Downloading and Installing XRDP..."
sudo apt update
sudo apt install xrdp -y
output "Adding XRDP to ssl-cert group"
sudo usermod -a -G ssl-cert xrdp
}
chgport() {
ask "Would you like to change the default XRDP port? (Y/n): "
read -r chport
if [ $chport == y ]; then
ask "What port do you desire to use?"
read -r port
re='^[0-9]+$'
if ! [[ $port =~ $re ]] ; then
error "Port should be a number!" >&2; exit 1
fi
lsof -i :$port
if [ $? == 1 ]; then
output "Port is OK"
sudo sed -i "s/\(port *= *\).*/\1$port/" /etc/xrdp/xrdp.ini
output "Port change success"
setup_xrdp
else
error "Port is not OK"; exit 1
fi
elif [ $chport == Y ]; then
ask "What port do you desire to use?"
read -r port
re='^[0-9]+$'
if ! [[ $port =~ $re ]] ; then
error "Port should be a number!" >&2; exit 1
fi
lsof -i :$port
if [ $? == 1 ]; then
output "Port is OK"
sudo sed -i "s/\(port *= *\).*/\1$port/" /etc/xrdp/xrdp.ini
output "Port change success"
setup_xrdp
else
error "Port is not OK"; exit 1
fi
else
port=3386
setup_xrdp
fi
}
setup_xrdp() {
sudo systemctl restart xrdp
sudo apt install ufw
ufw allow 3386
output "Install success!"
ip=$(curl -s https://api64.ipify.org/)
output "Use $ip:$port"
output "(for ipv6 only servers): [$ip]:$port using RDP Client to connect."
}
download
chgport