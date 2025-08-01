#!/bin/bash

STATE_FILE="/tmp/hypr_last_focused"

# Get list of clients sorted by last focus timestamp
clients=$(hyprctl clients -j | jq -c '.[] | {address, workspace: .workspace.id, title, class, pid, lastFocusTime}')

sorted_clients=$(echo "$clients" | jq -s 'sort_by(.lastFocusTime) | reverse')

# Get the currently focused window address
current=$(hyprctl activewindow -j | jq -r '.address')

# Find index of current window
index=$(echo "$sorted_clients" | jq --arg addr "$current" 'map(.address) | index($addr)')

# If current not found, fallback to first
[[ "$index" == "null" ]] && index=0

# Calculate next index
next_index=$(( (index + 1) % $(echo "$sorted_clients" | jq 'length') ))

# Get the address of the next window
next_address=$(echo "$sorted_clients" | jq -r ".[$next_index].address")

# Focus it
hyprctl dispatch focuswindow address:$next_address
