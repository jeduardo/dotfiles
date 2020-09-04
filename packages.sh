#!/bin/bash

PACKAGES=""

# Essential packages installation script
if [ "x$(uname)" == "xLinux" ]; then
  if [ "x$(lsb_release -s -i)" == "xDebian" ]; then
    PACKAGES="$PACKAGES xcompmgr libnotify-bin dunst xautolock maim exuberant-ctags"
    sudo apt-get install -y $PACKAGES
  fi
fi
