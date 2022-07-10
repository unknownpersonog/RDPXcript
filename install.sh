#!/bin/bash

set -e


SCRIPT_VERSION="main"
GITHUB_BASE_URL="https://raw.githubusercontent.com/unknownpersonog/CRDXcript"

LOG_PATH="/var/log/CRDXcript.log"
# exit with error status code if user is not root
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
  echo -e "\033[0;34m- ${1} \033[0m"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'
  

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

cat << "EOF" 
____________________________  __            _____        _____ 
__  ____/__  __ \__  __ \_  |/ /_______________(_)_________  /_
_  /    __  /_/ /_  / / /_    /_  ___/_  ___/_  /___  __ \  __/
/ /___  _  _, _/_  /_/ /_    | / /__ _  /   _  / __  /_/ / /_  
\____/  /_/ |_| /_____/ /_/|_| \___/ /_/    /_/  _  .___/\__/  
                                                 /_/           
                                                        
EOF
                                                       
execute() {
  echo -e "\n\n* CRDXcript $(date) \n\n" >>$LOG_PATH

  bash <(curl -s "$1") | tee -a $LOG_PATH
  [[ -n $2 ]] && execute "$2"
}

done=false

output "CRDXcript @ $SCRIPT_VERSION"
output
output "Made by UnknownGamer with love"
output "https://github.com/unknownpersonog/CRDXcript"
output
output "This script is non-official so please do no ask for Chrome Remote Desktop Community for help!"
output "Chrome Remote Desktop Script requires auth from google within 10 minutes of auth generation."

output

CRD_LATEST="$GITHUB_BASE_URL/$SCRIPT_VERSION/oscheck.sh"

CRD_CANARY="$GITHUB_BASE_URL/main/oscheck.sh"

while [ "$done" == false ]; do
  options=(
    "Install Chrome Remote Desktop"

    "Install Chrome Remote Desktop with developmemt version of the script (may be broken!)"
  )

  actions=(
    "$CRD_LATEST"

    "$CRD_CANARY"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done
  GC='\033[0;32m'
  NC='\033[0m'
  echo -e -n "${GC}- Input 0-$((${#actions[@]} - 1)):${NC} "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
done
