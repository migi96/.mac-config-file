#!/usr/bin/env zsh
# Rename the current kitty tab via remote control
printf "New tab name: "
read -r name
[ -z "$name" ] && exit 0
kitty @ set-tab-title "$name"
