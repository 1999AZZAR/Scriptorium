#!/bin/bash
#
# A robust screenshot script for Hyprland using grim, slurp, and wofi.
#

# --- Configuration ---
SAVE_DIR="${HOME}/Pictures/Screenshots"
EDITOR="swappy -f" # You can change this to another image editor like 'gimp'

# --- Pre-flight Checks ---
# Ensure the save directory exists
mkdir -p "$SAVE_DIR"

# Check for required commands
for cmd in wofi grim slurp wl-copy notify-send jq hyprctl; do
  if ! command -v "$cmd" &> /dev/null; then
    notify-send -u critical "Screenshot Script Error" "'$cmd' is not installed. Please install it to continue."
    exit 1
  fi
done

# --- Main Logic ---

# 1. Ask for the type of screenshot
TYPE_OPTIONS="󰹑 Fullscreen\n󰆞 Area\n󰖵 Window"
SELECTED_TYPE=$(echo -e "$TYPE_OPTIONS" | wofi --dmenu --prompt="Select capture type")
if [[ -z "$SELECTED_TYPE" ]]; then
    exit 0
fi

# 2. Ask for the desired action
# Note: Corrected the "Edit" option for clarity
ACTION_OPTIONS="󰆓 Save\n󰅍 Copy\n󰃆 Save & Copy\n󰏫 Edit"
SELECTED_ACTION=$(echo -e "$ACTION_OPTIONS" | wofi --dmenu --prompt="Select action")
if [[ -z "$SELECTED_ACTION" ]]; then
    exit 0
fi

# 3. Determine the capture geometry based on the selected type
GEOMETRY=""
case "$SELECTED_TYPE" in
    "󰹑 Fullscreen")
        # grim captures the entire output by default if no geometry is given
        GEOMETRY=""
        ;;
    "󰆞 Area")
        GEOMETRY=$(slurp -d)
        ;;
    "󰖵 Window")
        # Get the geometry of the currently focused window in Hyprland
        GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        ;;
    *)
        exit 0
        ;;
esac

# Handle cancellation of slurp (by pressing Esc)
if [[ -z "$GEOMETRY" && "$SELECTED_TYPE" == "󰆞 Area" ]]; then
    notify-send "Screenshot" "Screenshot cancelled."
    exit 0
fi

# --- Add a small delay ---
# This gives the compositor time to close the wofi menu before taking the screenshot.
sleep 0.2

# 4. Perform the capture and action
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILE_PATH="$SAVE_DIR/Screenshot_${TIMESTAMP}.png"
NOTIF_TITLE=""
NOTIF_BODY=""

# The core command to capture the screen
capture_cmd() {
    if [[ -z "$GEOMETRY" ]]; then
        grim -
    else
        grim -g "$GEOMETRY" -
    fi
}

case "$SELECTED_ACTION" in
    "󰆓 Save")
        capture_cmd > "$FILE_PATH"
        NOTIF_TITLE="Screenshot Saved"
        NOTIF_BODY="Saved to <b>$FILE_PATH</b>"
        ;;
    "󰅍 Copy")
        capture_cmd | wl-copy --type image/png
        NOTIF_TITLE="Screenshot Copied"
        NOTIF_BODY="Image copied to clipboard."
        # Use a generic icon since there's no file to show
        FILE_PATH="screenshot"
        ;;
    "󰃆 Save & Copy")
        capture_cmd | tee "$FILE_PATH" | wl-copy --type image/png
        NOTIF_TITLE="Saved & Copied"
        NOTIF_BODY="Saved to <b>$FILE_PATH</b> and copied."
        ;;
    "󰏫 Edit") # Note: Matched this to the corrected option
        capture_cmd | $EDITOR
        # The editor handles saving/copying, so we don't send a notification here.
        exit 0
        ;;
esac

# 5. Send a confirmation notification
if [[ -f "$FILE_PATH" ]]; then
    notify-send "$NOTIF_TITLE" "$NOTIF_BODY" -i "$FILE_PATH" -a "Screenshot"
else
    # This handles the "Copy" case where no file is saved
    notify-send "$NOTIF_TITLE" "$NOTIF_BODY" -i "$FILE_PATH" -a "Screenshot"
fi
