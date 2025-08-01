#!/bin/bash

CONFIG_DIR="$HOME/.config/waybar"
ACTIVE_CONFIG="$CONFIG_DIR/config"
STATE_FILE="$CONFIG_DIR/.current_config_state" # New file to store the current state

# --- Add all your config files to this list ---
CONFIG_FILES=(
  "$CONFIG_DIR/config_library/config-1"
  "$CONFIG_DIR/config_library/config-2"
  "$CONFIG_DIR/config_library/config-3"
  "$CONFIG_DIR/config_library/config-4"
  "$CONFIG_DIR/config_library/config-5"
)
# ------------------------------------------------

# --- Find current config by reading the state file, not by comparing ---
current_index=-1
# Check if the state file exists and has content
if [ -f "$STATE_FILE" ]; then
  current_config_path=$(cat "$STATE_FILE")
  # Find the index of the path from the state file
  for i in "${!CONFIG_FILES[@]}"; do
    if [[ "${CONFIG_FILES[$i]}" == "$current_config_path" ]]; then
      current_index=$i
      break
    fi
  done
fi

# Determine the next config index, wrapping around at the end
if [ $current_index -eq -1 ]; then
  # If state is unknown or file doesn't exist, default to the first one
  next_index=0
else
  next_index=$(((current_index + 1) % ${#CONFIG_FILES[@]}))
fi

# Get the path of the config we are switching to
new_config_path="${CONFIG_FILES[$next_index]}"

# Copy the next config file to be the active one
cp "$new_config_path" "$ACTIVE_CONFIG"

# Save the path of the new config to the state file for the next run
echo "$new_config_path" >"$STATE_FILE"

# --- Notification ---
new_config_filename=$(basename "$new_config_path")
notify-send "Waybar" "Switched to: $new_config_filename"

# Kill and restart Waybar
killall -q waybar
while pgrep -x waybar >/dev/null; do sleep 0.1; done
waybar &
"$CONFIG_DIR/config-4"
