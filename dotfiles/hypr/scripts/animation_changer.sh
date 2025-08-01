#!/bin/bash

# --- Configuration ---
# Directory where your animation profiles (1.conf, 2.conf, etc.) are stored.
PROFILES_DIR="$HOME/.config/hypr/animations"

# The file that hyprland.conf will source. This will be a symbolic link.
ACTIVE_CONF_SYMLINK="$HOME/.config/hypr/animation.conf"
# --- End of Configuration ---

# Check if the profiles directory exists
if [ ! -d "$PROFILES_DIR" ]; then
    notify-send "Hyprland Animations" "Error: Profiles directory not found at $PROFILES_DIR"
    exit 1
fi

# Get a sorted list of available .conf files in the directory
# 'ls -v' sorts numerically (e.g., 1, 2, 10) instead of alphabetically (1, 10, 2)
profiles=($(ls -v "$PROFILES_DIR"/*.conf))

# Check if any profiles were found
if [ ${#profiles[@]} -eq 0 ]; then
    notify-send "Hyprland Animations" "Error: No .conf files found in $PROFILES_DIR"
    exit 1
fi

# Find the current profile by reading the symbolic link
current_index=-1
if [ -L "$ACTIVE_CONF_SYMLINK" ]; then
    current_target=$(readlink "$ACTIVE_CONF_SYMLINK")
    for i in "${!profiles[@]}"; do
        if [[ "${profiles[$i]}" == "$current_target" ]]; then
            current_index=$i
            break
        fi
    done
fi

# Calculate the index of the next profile, wrapping around to the start
next_index=$(( (current_index + 1) % ${#profiles[@]} ))
next_profile_path=${profiles[$next_index]}
next_profile_name=$(basename "$next_profile_path")

# Update the symbolic link to point to the next profile
# -f ensures we remove the old link before creating a new one
ln -sf "$next_profile_path" "$ACTIVE_CONF_SYMLINK"

# Get the first line of the new profile to use as a description (optional but cool)
description=$(head -n 1 "$next_profile_path" | sed 's/# //')

# Reload Hyprland to apply the new settings and send a notification
hyprctl reload
notify-send "Hyprland Animations" "Switched to: $description"

exit 0
