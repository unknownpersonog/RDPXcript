#!/bin/bash
output() {
  echo -e "\033[0;34m[RDPXcript] ${1} \033[0m"
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

username="$1"

output "*****************************"
output "Audio will not work in VPSes."
output "Proceeding in 5s"
output "*****************************"

sleep 5

gui_install() {
output "Installing XFCE GUI"
sudo DEBIAN_FRONTEND=noninteractive \
    apt install --no-install-recommends --assume-yes xfce4 desktop-base dbus-x11 xscreensaver
[ $? -eq 0 ] && output "XFCE Install success" && depend_install || error "Failed to install XFCE" && exit 1
}

depend_install() {
    sudo apt install -y tigervnc-standalone-server tigervnc-common
[ $? -eq 0 ] && output "Dependency Install success" && vnc_setup || error "Failed to install dependencies" && depend_fix
}

depend_fix() {
sudo apt --fix-broken install
[ $? -eq 0 ] && output "Fixed dependencies" && vnc_setup || error "Failed to fix dependencies" && exit 1
}

vnc_setup() {
output "Add a password to secure your server. If nothing is visible just type password and press enter and again type password and press enter"
sudo -H -u "$username" bash -c vncpasswd
[ $? -eq 0 ] && output "VNC Password entry success" && vnc_teststart || error "Failed to password protect VNC" && exit 1
}

vnc_teststart() {
sudo -H -u "$username" bash -c vncserver -localhost no
[ $? -eq 0 ] && output "VNC Startup success" && vnc_kill || error "Failed to start VNC" && exit 1
}

vnc_kill() {
sudo -H -u "$username" bash -c 'vncserver -kill :*'
[ $? -eq 0 ] && output "VNC Killed Successfully" && vnc_start || error "Failed to kill VNC" && exit 1
}

vnc_start() {
  sudo -H -u "$username" bash -c vncserver
  [ $? -eq 0 ] && output "VNC Startup success" && goodbye|| error "Failed to start VNC" && exit 1
}
goodbye() {
  if [[ "$IPV6" == y ]]; then
  vnc_port=$(lsof -i tcp -P | grep "vnc" | grep IPv6 | awk '{print $9}' | cut -d ":" -f 2 | head -n 1)
  ip=$(curl -6 -s https://api64.ipify.org/)
  output "VNC Installed. Accessing at a vnc viewer using "$ip":"$vnc_port""
  elif [[ "$IPV6" == n ]]; then
  vnc_port=$(lsof -i tcp -P | grep "vnc" | grep IPv4 | awk '{print $9}' | cut -d ":" -f 2 | head -n 1)
  ip=$(curl -4 -s https://api64.ipify.org/)
  output "VNC Installed. Accessing at a vnc viewer using $ip:$vnc_port"  
  else
  error "Some error occurred" && exit 1
  fi
}

ask "Is Your VPS IPv6 Only? (Y/n): "
read -r ipv46
if [[ "$ipv46" == Y ]]; then
IPV6="y"
gui_install
elif [[ "$ipv46" == y ]]; then
IPV6="y"
gui_install
elif [[ "$ipv46" == N ]]; then
IPV6="n"
gui_install
elif [[ "$ipv46" == n ]]; then
IPV6="n"
gui_install
else
error "Invalid Choice" && exit 1
fi

