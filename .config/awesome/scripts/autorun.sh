#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run picom -b
run nm-applet --no-agent

# disable screensaver
run xset s off
run xset -dpms
run xset s noblank

# polkit agent
run lxqt-policykit-agent

# JamesDSP
run jamesdsp --tray