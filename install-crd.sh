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
detect_distro() {
  if type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}
os_check() {
detect_distro
if [[ $OS == debian ]]; then
   echo -e "\033[0;34m- Found Current OS: $OS\033[0m"
elif [[ $OS == ubuntu ]]; then
   output "Found Current OS: $OS"
else
   output "Unsupported OS!"
   exit 1
fi
}
user() {
output "Enter details for user to configure with Chrome Remote Desktop. (Only New User Creation Supported!)"
        ask "Enter Username for CRD: "
	read -r username
	user_check=$(grep -c "^$username:" /etc/passwd)
	if [[ "$username" == root ]]; then
	output "Root user is not supported!"
	exit 1
	elif [ "$user_check" == 0 ]; then
	user_pass
        
	else
		ask "$username exists! Continue with it? (y/N): "
		read -r continue
		case $continue in
		y)
                crd_setup
                ;;

                Y) 
                crd_setup
                ;;
		
		*) 
                output "Username already exists!" && exit 1
                ;;
		esac
	fi
}
user_pass() {
	ask "Enter password to setup user: "
	read -r password
		pass=$(perl -e 'print crypt($ARGV[0], "password")' "$password")
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && output "User has been added to system!" || output "Failed to add a user!" && exit 1
}
os_check
user
