#!/usr/bin/env sh

# Check current blur status to determine mode
HYPRGAMEMODE=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}')

if [ "$HYPRGAMEMODE" = 1 ]; then
    # Entering Game Mode
    if command -v notify-send &> /dev/null; then
        notify-send -t 3000 "Game Mode" "Entering Game Mode - Performance optimized" -i applications-games
    fi

    hyprctl --batch "\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 10;\
        keyword animations:enabled 0"
    exit
fi

# Exiting Game Mode
if command -v notify-send &> /dev/null; then
    notify-send -t 3000 "Game Mode" "Exiting Game Mode - Restoring visual effects" -i preferences-desktop-effects
fi

hyprctl reload
