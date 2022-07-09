#!/bin/bash

set -e

output() {
  echo -e "\033[0;34m- ${1} \033[0m"
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
# Purpose - Script to add a user to Linux system including passsword
# Author - Vivek Gite <www.cyberciti.biz> under GPL v2.0+
# ------------------------------------------------------------------
# Am i Root user?
if [ $(id -u) -eq 0 ]; then
        echo -e -n "Enter Username for CRD: "
	read -r username
	if [[ "$username" == root ]]; then
	output "Root user is not supported!"
	exit 1
	fi
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo -e -n "$username exists! Continue with it? (y/N): "
		read -r continue
		if [[ "$continue" =~ [yY] ]]; then
		setup_crd
		else
		output "Username exists!"
		exit 2
	fi	
	read -s -p "Enter password to setup user: " password
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && output "User has been added to system!" || output "Failed to add a user!" && exit 3
	fi
else
	echo -e "Only root may add a user to the system"
	exit 4
fi
}
os_check
user
