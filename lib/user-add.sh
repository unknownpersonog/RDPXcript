#!/bin/bash
# Purpose - Script to add a user to Linux system including passsword
# Author - Vivek Gite <www.cyberciti.biz> under GPL v2.0+
# ------------------------------------------------------------------
# Am i Root user?
output() {
  echo -e "\033[0;34m- ${1} \033[0m"
}
ask() {
  GC='\033[0;32m'
  NC='\033[0m'
  echo -e -n "${GC}- ${1}${NC} "
}

error() {
  RC='\033[0;31m'
  NC='\033[0m'
  echo -e "${RC}ERROR: ${1}${NC}"
}

if [ $(id -u) -eq 0 ]; then
	ask "Enter username to setup with CRD: "
	read -p username
	ask "Enter password for user: "
	read -s -p password
	if [[ "$username" == root ]]
	then
	error "Root user is not allowed!"
	exit 1
	fi
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		ask "Do you want continue with this user? (y/N): "
		read -r continue
		if [[ "$continue" =~ [Yy] ]]
		then
		crd_setup
		else
		error "\nUser already exists"
		exit 1
		fi
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && output "\nUser has been added to system!" || error "\nFailed to add a user!"
	fi
else
	echo "Only root may add a user to the system."
	exit 2
fi
