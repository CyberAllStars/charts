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

# Function to install devspace
install_devspace() {
  echo 1
  if check_command brew; then
      brew_install devspace
  else
    if [ "$OS" = "mac" ]; then
        curl_install devspace "https://github.com/loft-sh/devspace/releases/latest/download/devspace-darwin-$ARCH"
    fi

    if [ "$OS" = "Linux" ]; then
      #devspace https://www.devspace.sh/docs/getting-started/installation?x0=5
        curl -L -o devspace "https://github.com/loft-sh/devspace/releases/latest/download/devspace-linux-amd64" && sudo install -c -m 0755 devspace /usr/local/bin
    fi
  fi

}

# Function to install tilt
install_tilt() {
  if [ "$OS" = "mac" ] || [ "$OS" = "Linux" ]; then
    curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
  fi

}

# Function to install docker
install_docker() {
  if [ "$OS" = "mac" ]; then
    if check_command brew; then
      brew_install docker
    else
      curl -L -o docker "https://download.docker.com/mac/static/stable/x86_64/docker-$VERSION.tgz"
      tar -xzf docker
      sudo mv docker/* /usr/local/bin/
    fi
  fi
}


install_docker_compose() {
  VERSION="2.6.0"
  if check_command brew; then
      brew_install docker-compose
  else
    if [ "$OS" = "mac" ]; then
      curl -L -o docker-compose "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-`uname -s`-`uname -m`"
      chmod +x docker-compose
      sudo mv docker-compose /usr/local/bin/
    fi

    if [ "$OS" = "Linux" ]; then
      echo 1
    fi
fi

}

install_rancher_desktop() {
  VERSION="2.6.0"
  if check_command brew; then
      brew_install --cask rancher-desktop
  else
    if [ "$OS" = "mac" ]; then
         curl -L -o rancher-desktop.dmg "https://github.com/rancher-sandbox/rancher-desktop/releases/download/v$VERSION/rancher-desktop-$VERSION.dmg"
      hdiutil attach -noverify -nobrowse -mountpoint /Volumes/rancher-desktop rancher-desktop.dmg
      sudo installer -pkg /Volumes/rancher-desktop/*.pkg -target /
      hdiutil detach /Volumes/rancher-desktop
    fi

    if [ "$OS" = "Linux" ]; then
      curl -s https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/Release.key | gpg --dearmor | sudo dd status=none of=/usr/share/keyrings/isv-rancher-stable-archive-keyring.gpg
      echo 'deb [signed-by=/usr/share/keyrings/isv-rancher-stable-archive-keyring.gpg] https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/ ./' | sudo dd status=none of=/etc/apt/sources.list.d/isv-rancher-stable.list
      sudo apt update
      sudo apt install rancher-desktop
    fi
  fi

}

# Main function
main() {
  OS=$(uname -s)
  ARCH=$(uname -m)

  # Check the given env vars and install the corresponding packages
  if [ -n "$DEVSPACE" ]; then
    install_devspace
  fi

  if [ -n "$TILT" ]; then
    install_tilt
  fi

  if [ -n "$DOCKER" ]; then
    install_docker
  fi

  if [ -n "$DOCKER_COMPOSE" ]; then
    install_docker_compose
  fi

  if [ -n "$RANCHER_DESKTOP" ]; then
    install_rancher_desktop
  fi
}

# Run the main function
main

