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
detect_distro
if [[ $OS == debian ]]; then
   echo -e "\033[0;34m- Found Current OS: $OS\033[0m"
elif [[ $OS == ubuntu ]]; then
   output "Found Current OS: $OS"
else
   output "Unsupported OS!"
   exit 1
fi