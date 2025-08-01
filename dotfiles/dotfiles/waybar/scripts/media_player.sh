#!/bin/bash

# This script gets the current media player status and formats it for Waybar
# with a detailed tooltip.

PLAYERCTL_STATUS=$(playerctl status 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    PLAYER_STATUS_ICON="▶"
    if [ "$PLAYERCTL_STATUS" = "Paused" ]; then
        PLAYER_STATUS_ICON="⏸"
    fi

    # Get metadata
    ARTIST=$(playerctl metadata artist)
    TITLE=$(playerctl metadata title)
    ALBUM=$(playerctl metadata album)

    # Get song length
    POSITION=$(playerctl position --format '{{ duration(position) }}')
    LENGTH=$(playerctl metadata mpris:length | xargs -I {} echo "scale=0; {}/1000000" | bc | awk '{printf "%d:%02d", $1/60, $1%60}')

    # Truncate long titles for the main bar display
    DISPLAY_TITLE=$TITLE
    if [ ${#DISPLAY_TITLE} -gt 25 ]; then
        DISPLAY_TITLE="$(echo "$DISPLAY_TITLE" | cut -c1-25)..."
    fi

    # Build the tooltip
    TOOLTIP="Artist: $ARTIST\n"
    TOOLTIP+="Title: $TITLE\n"
    TOOLTIP+="Album: $ALBUM\n"
    TOOLTIP+="Track: $TRACK_NUM\n"
    TOOLTIP+="Position: $POSITION / $LENGTH"

    echo "{\"text\":\"$PLAYER_STATUS_ICON $ARTIST - $DISPLAY_TITLE\", \"class\":\"$PLAYERCTL_STATUS\", \"tooltip\":\"$TOOLTIP\"}"
else
    echo "{\"text\":\"No player active\", \"class\":\"stopped\", \"tooltip\":\"No media player is currently active.\"}"
fi
