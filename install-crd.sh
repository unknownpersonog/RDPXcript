#!/bin/bash

set -e

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
asknl "1] LXDE"
output "Problematic GUIs have been removed."
ask "Select GUI (1-1): "
read -r gui
if [[ "$gui" == 1 ]]; then
lxde_install
else
output "Use Valid Input (1-5)!"
exit 1
fi
}
lxde_install() {
sudo DEBIAN_FRONTEND=noninteractive \
    apt install --no-install-recommends --assume-yes lxde
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/startlxde" > /etc/chrome-remote-desktop-session'
auth
}
auth() {
output "GUI Installed"
output "Please go to https://remotedesktop.google.com/headless and click Begin -> Next -> Authorize -> Copy code for Debian Linux"
ask "Paste the code here: "
read -r code
cat <<EOF >code.sh
$code --user-name=$username
EOF
if bash code.sh; then
output "Chrome Remote Desktop Installation Success! Access it at https://remotedesktop.google.com/access"
sudo systemctl enable chrome-remote-desktop@$username
rm -rf code.sh
else
error "Code Execution Failed! Try Again?" & rm -rf code.sh & exit 1;
fi
exit 0
}
main() {
username="$1"
download
gui_install
}
main "$1"
