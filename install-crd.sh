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
if [[ $(/usr/bin/lsb_release --codename --short) == "stretch" ]]; then
   sudo apt install --assume-yes libgbm1/stretch-backports
fi
output "If you get missing dependency error, the script fixes it itself!"
mkdir /crdxcript
cd /crdxcript
curl -Lo chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i /crdxcript/chrome-remote-desktop_current_amd64.deb || sudo apt install --no-install-recommends --assume-yes --fix-broken
cd
output "Chrome Remote Desktop Installation Completed!"
rm -r /crdxcript
}
gui_install() {
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
exit 1
fi
}
xfce4_install() {
sudo DEBIAN_FRONTEND=noninteractive \
    apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
auth
}
cinnamon_install() {
sudo DEBIAN_FRONTEND=noninteractive \
    apt install --assume-yes cinnamon-core desktop-base dbus-x11
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session'
auth
}
gnome_install() {
sudo DEBIAN_FRONTEND=noninteractive \
    apt install --assume-yes  task-gnome-desktop
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session'
auth
}
gnomeclassic_install() {
sudo DEBIAN_FRONTEND=noninteractive \
    apt install --assume-yes  task-gnome-desktop
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/gnome-session-classic" > /etc/chrome-remote-desktop-session'
auth
}
kdeplasma_install() {
sudo DEBIAN_FRONTEND=noninteractive \
    apt install --assume-yes  task-kde-desktop
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/startkde" > /etc/chrome-remote-desktop-session'
auth
}
auth() {
output "GUI Installed"
output "Script will switch to "$username" due to some issues with root. "$username" will also have sudo temporarily."
output "Please go to https://remotedesktop.google.com/headless and click Begin -> Next -> Authorize -> Copy code for Debian"
ask "Paste the code here: "
read -r code
usermod -aG sudo "$username"
su - "$username"
bash -c "$code"
sudo gpasswd -d "$username" sudo
}
main() {
username="$1"
download
gui_install
}
main "$1"
