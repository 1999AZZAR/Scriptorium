#!/bin/bash

# ==============================================================================
# Smart Manual Session Launcher
#
# Description:
#   This script provides a simple menu to allow the user to either
#   start a Hyprland session or remain in the current TTY.
#   It includes smart detection: if run on TTY1, it will automatically
#   launch Hyprland without showing the menu.
#
# Usage:
#   Run this script from your TTY after logging in.
#   For example: ./start_session.sh
#
# Author: azzar (user-provided) & Gemini
# Version: 2.0
# ==============================================================================

# Check if the current terminal is TTY1
if [ "$(tty)" == "/dev/tty1" ]; then
  # If on TTY1, launch Hyprland directly.
  echo "Detected TTY1. Launching Hyprland automatically..."
  exec Hyprland
else
  # If not on TTY1, show the manual selection menu.
  clear

  echo "========================================"
  echo "           Session Login            "
  echo "========================================"
  echo "1) Hyprland"
  echo "2) Stay in TTY"

  read -rp "Select your session (1/2): " choice

  case "$choice" in
  1)
    echo "Launching Hyprland..."
    exec Hyprland
    ;;
  2)
    echo "Staying in TTY. No graphical session will be started."
    ;;
  *)
    echo "Invalid input. Staying in TTY."
    ;;
  esac
fi
