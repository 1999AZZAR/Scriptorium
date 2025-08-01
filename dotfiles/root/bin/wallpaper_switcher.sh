#!/bin/bash

WALLPAPER_DIR="$HOME/dotfiles/wallpapers"
CURRENT_WALLPAPER_FILE="$HOME/.cache/current_wallpaper"
HYPRLOCK_WALLPAPER_CONF="$HOME/.cache/hyprlock_wallpaper.conf"

# Ensure the cache directory exists
mkdir -p "$HOME/.cache"

# Get a list of all image files in the directory
# Sort them to ensure consistent cycling
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | sort))

# Check if there are any wallpapers
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
  echo "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# Read the current wallpaper index
if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
  CURRENT_INDEX=$(cat "$CURRENT_WALLPAPER_FILE")
else
  CURRENT_INDEX=-1 # Start from the beginning if no file
fi

# Calculate the next index
NEXT_INDEX=$(((CURRENT_INDEX + 1) % ${#WALLPAPERS[@]}))

# Get the next wallpaper path
NEXT_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

# Set the wallpaper using swww
swww img "$NEXT_WALLPAPER"

# Save the new current index
echo "$NEXT_INDEX" >"$CURRENT_WALLPAPER_FILE"
echo "Wallpaper set to: $NEXT_WALLPAPER"
echo "Hyprlock config updated at: $HYPRLOCK_WALLPAPER_CONF"
