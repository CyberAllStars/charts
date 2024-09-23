#!/bin/bash

PREFXCMD="echo " #tsting

#do system/arch checks / OSX/Linux etc
case "$(uname -s)" in
   Darwin)
     OS=mac
     ;;
   Linux)
     OS=linux
     ;;
   *)
     echo "Unsupported OS: $(uname -s)"
     exit 1
     ;;
esac

if [ "$(uname -m)" = "x86_64" ]; then
  ARCH=amd64
else
  if [ "$(uname -m)" = "arm64" ]; then
    ARCH=arm64
  else
    echo "Unsupported arch: $(uname -m)"
    exit 1
  fi
fi

BREW_AVAILABLE=false
# TODO: LinuxBrew
if [ -d "/usr/local/Homebrew" ]; then
  echo "Homebrew exists"
  BREW_AVAILABLE=true
else
  if [ "$OS" = "mac" ]; then
    if command -v brew &> /dev/null; then
      BREW_AVAILABLE=true
    else
      echo "Homebrew does not exist"
      BREW_AVAILABLE=false
    fi

fi

# install 


# if [ "$OS" = "mac" ]; then

# #tilt #https://docs.tilt.dev/install.html
#   curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
  
#   if [ "$BREW_AVAILABLE" = true ]; then
#     brew install devspace
#     else 
          
#       # ARCH CHECK
#       if [ "$(uname -m)" = "x86_64" ]; then
#       #devspace https://www.devspace.sh/docs/getting-started/installation?x0=5
#           curl -L -o devspace "https://github.com/loft-sh/devspace/releases/latest/download/devspace-darwin-amd64" && sudo install -c -m 0755 devspace /usr/local/bin
#       elif [ "$(uname -m)" = "arm64" ]; then
#       #devspace https://www.devspace.sh/docs/getting-started/installation?x0=5
#           curl -L -o devspace "https://github.com/loft-sh/devspace/releases/latest/download/devspace-darwin-arm64" && sudo install -c -m 0755 devspace /usr/local/bin
#       else
#           echo "Unsupported arch: $(uname -m)"
#           exit 1
#       fi

#   fi
  
# fi


if [ "$OS" = "linux" ]; then
  curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

  if [ "$BREW_AVAILABLE" = true ]; then
    brew install devspace
  else 
    # ARCH CHECK
    if [ "$(uname -m)" = "x86_64" ]; then
    #devspace https://www.devspace.sh/docs/getting-started/installation?x0=5
        curl -L -o devspace "https://github.com/loft-sh/devspace/releases/latest/download/devspace-linux-amd64" && sudo install -c -m 0755 devspace /usr/local/bin
  fi

fi

# install docker / docker-compose / rancher-desktop  - pref rancher - docker-desktop licensing possible issues for enterprises 
#https://docs.rancherdesktop.io/getting-started/installation/

# install Make / build-tools

