#!/bin/bash
# Purpose - Script to add a user to Linux system including passsword
# Author - Vivek Gite <www.cyberciti.biz> under GPL v2.0+
# ------------------------------------------------------------------
# Am i Root user?
output() {
  echo -e "\033[0;34m\n- ${1} \033[0m"
}
ask() {
  GC='\033[0;32m'
  NC='\033[0m'
  echo -e -n "${GC}- ${1}${NC} "
}

error() {
  RC='\033[0;31m'
  NC='\033[0m'
  echo -e "${RC}\nERROR: ${1}${NC}"
}

if [ $(id -u) -eq 0 ]; then
	ask "Enter username to setup with CRD: "
	read username
	ask "Enter password for user: "
	read -s password
	if [[ "$username" == root ]]
	then
	error "Root user is not allowed!"
	exit 1
	fi
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		output "$username exists!"
		ask "Do you want continue with this user? (y/N): "
		read -r continue
		if [[ "$continue" =~ [Yy] ]]
		then
		crd_setup
		else
		error "User already exists"
		exit 1
		fi
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && output "User has been added to system!" || error "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system."
	exit 2
fi
bash <(curl -s https://raw.githubusercontent.com/unknownpersonog/CRDXcript/main/install-crd.sh) ${username}
