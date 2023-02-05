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
su - "$username"
output "Add a password to secure your server"
vncpasswd
[ $? -eq 0 ] && output "VNC Password entry success" && vnc_teststart || error "Failed to password protect VNC" && exit 1
}

vnc_teststart() {
vncserver -localhost no
[ $? -eq 0 ] && output "VNC Startup success" && vnc_config || error "Failed to start VNC" && exit 1
}

vnc_config() {
vncserver -kill :*
[ $? -eq 0 ] && output "VNC Killed Successfully" || error "Failed to kill VNC" && exit 1
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
[ $? -eq 0 ] && output "Created xstartup backup" || error "Failed to create xstartup backup" && exit 1
echo -e '#!/bin/bash \nxrdb $HOME/.Xresources \nstartxfce4 &' > ~/.vnc/xstartup
sudo chmod u+x  ~/.vnc/xstartup 
sudo chmod 777 ~/.vnc/xstartup
[ $? -eq 0 ] && output "VNC Configured" && vnc_start || error "Failed to configure VNC" && exit 1
}
vnc_start() {
  vncserver
  [ $? -eq 0 ] && output "VNC Startup success" && goodbye|| error "Failed to start VNC" && exit 1
}
goodbye() {
  if [[ "$IPV6" == y ]]; then
  vps_port=$(lsof -i tcp -P | grep "vnc" | grep IPv6 | awk '{print $9}' | cut -d ":" -f 2 | head -n 1)
  ip=$(curl -6 -s https://api64.ipify.org/)
  output "VNC Installed. Accessing at a vnc viewer using $ip:$vnc_port"
  elif [[ "$IPV6" == n ]]; then
  vps_port=$(lsof -i tcp -P | grep "vnc" | grep IPv4 | awk '{print $9}' | cut -d ":" -f 2 | head -n 1)
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

