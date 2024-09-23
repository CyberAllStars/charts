#!/bin/bash
source .env

# Check if the given command is available
check_command() {
  echo $1
  command -v "$1" &> /dev/null
}

# Install the given package using brew
brew_install() {
  if check_command brew; then
    brew install "$1"
    echo "brew install $1"
  else
    echo "Brew is not available"
    exit 1
  fi
}

# Install the given package using a curl download
curl_install() {
  if [ ! -f "$1" ]; then
    curl -L -o "$1" "$2"
    chmod +x "$1"
    sudo mv "$1" /usr/local/bin/
  fi
}


install_digitalocean_cli() {
  
  if check_command brew; then
      brew install doctl
  elif check_command snap; then
      sudo snap install doctl
      sudo snap connect doctl:kube-config
      sudo snap connect doctl:ssh-keys :ssh-keys
      sudo snap connect doctl:dot-docker
  else
    if [ "$OS" = "mac" ]; then
     echo 1
    fi

    if [ "$OS" = "Linux" ]; then
      echo 1
    fi
  fi

    #git submodule add https://github.com/digitalocean/doctl.git ~/.doctl

}

# Main function
main() {
  OS=$(uname -s)
  ARCH=$(uname -m)

  # Check the given env vars and install the corresponding packages
  if [ -n "$DIGITALOCEAN_CLI" ]; then
    install_digitalocean_cli
  fi

}

# Run the main function
main

