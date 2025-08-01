#!/bin/sh

# Define the path for our lock directory
LOCK_DIR="/tmp/waybar-scroll.lock"

# Try to create the lock directory. If it fails, another instance is running.
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi

# Ensure the lock directory is removed automatically when the script exits.
trap 'rm -rf "$LOCK_DIR"' EXIT

# Execute the workspace change.
hyprctl dispatch workspace "$1"

# Add the 0.5-second delay before releasing the lock.
sleep 0.5
#!/bin/sh

# Define the path for our lock directory
LOCK_DIR="/tmp/waybar-scroll.lock"

# Try to create the lock directory. If it fails, another instance is running.
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi

# Ensure the lock directory is removed automatically when the script exits.
trap 'rm -rf "$LOCK_DIR"' EXIT

# Execute the workspace change.
hyprctl dispatch workspace "$1"

# Add the 0.5-second delay before releasing the lock.
sleep 0.5
