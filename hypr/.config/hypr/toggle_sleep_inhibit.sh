#!/bin/bash

# Unique identifier for the inhibition
WHY="Hyprland Stay Awake"

if pgrep -f "systemd-inhibit.+$WHY" > /dev/null; then
    pkill -f "systemd-inhibit.+$WHY"
else
    nohup systemd-inhibit --what=sleep --why="$WHY" sleep infinity >/dev/null 2>&1 &
fi
