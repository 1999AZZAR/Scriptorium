#!/bin/bash
#
# Sends files to a KDE Connect device.
# Automatically uses kdialog (for KDE) or zenity (for GTK/other DEs).
#

# --- Configuration ---
# Command to send notifications.
NOTIFICATION_CMD="notify-send"

# --- Script ---

# 1. Find the first available (paired and reachable) device.
DEVICE_ID=$(kdeconnect-cli -a --id-only 2>/dev/null | head -n 1)

# Exit if no reachable device was found.
if [[ -z "$DEVICE_ID" ]]; then
  "$NOTIFICATION_CMD" -a "KDE Connect" -u critical "File Share Error" "No reachable device found."
  exit 1
fi

# 2. Get the device name for use in notifications.
DEVICE_NAME=$(kdeconnect-cli -d "$DEVICE_ID" --name 2>/dev/null || echo "Unknown Device")

# 3. Use the best available file picker.
# We'll try kdialog first, then fall back to zenity.
if command -v kdialog &>/dev/null; then
  # KDE environment: use kdialog.
  SELECTED_FILES=$(kdialog --getopenfilename --multiple --separate-output . "Select files to send to ${DEVICE_NAME}")
elif command -v zenity &>/dev/null; then
  # GTK/other environment: use zenity as a fallback.
  SELECTED_FILES=$(zenity --file-selection --multiple --separator='\n' --title="Select files to send to ${DEVICE_NAME}")
else
  # No suitable file picker found.
  "$NOTIFICATION_CMD" -a "KDE Connect" -u critical "Dependency Error" "Neither kdialog nor zenity is installed."
  exit 1
fi

# Exit if the user cancelled the dialog (non-zero exit code).
if [[ $? -ne 0 ]]; then
  exit 0
fi

# 4. Send each selected file.
echo "$SELECTED_FILES" | while IFS= read -r file; do
  # Check if the file path is not empty and the file actually exists.
  if [[ -n "$file" && -e "$file" ]]; then
    # Send the file in the background (&).
    kdeconnect-cli --share "$file" -d "$DEVICE_ID" &
    "$NOTIFICATION_CMD" -a "KDE Connect" "Sending File" "<b>$(basename "$file")</b> to ${DEVICE_NAME}"
  fi
done

exit 0
