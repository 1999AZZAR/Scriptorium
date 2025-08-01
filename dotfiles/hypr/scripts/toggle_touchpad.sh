#!/bin/bash

# Touchpad Toggle Script for Hyprland
# This script toggles the touchpad on/off and shows notifications

# Configuration
TOUCHPAD_DEVICE=""
NOTIFICATION_TIMEOUT=3000

# Function to find touchpad device
find_touchpad() {
    # Try common touchpad identifiers
    local touchpad_names=(
        "synaptics-tm3336-001"
        "Touchpad"
        "TouchPad"
        "trackpad"
        "TrackPad"
        "Synaptics"
        "synaptics"
        "ELAN"
        "bcm5974"
        "PS/2"
    )

    for name in "${touchpad_names[@]}"; do
        local device=$(hyprctl devices | grep -i "$name" | head -1 | awk '{print $1}')
        if [[ -n "$device" ]]; then
            echo "$device"
            return 0
        fi
    done

    # Try to find device in the mice section (since your touchpad appears under mice)
    local device=$(hyprctl devices | grep -A 10 "mice:" | grep -E "synaptics|touchpad|trackpad" | head -1 | awk '{print $1}')
    if [[ -n "$device" ]]; then
        echo "$device"
        return 0
    fi

    return 1
}

# Function to check if touchpad is enabled
is_touchpad_enabled() {
    local device="$1"

    # Check in mice section first (for devices like synaptics-tm3336-001)
    local mouse_status=$(hyprctl devices | grep -A 5 "mice:" | grep -A 2 "$device" | grep -i "disabled" | awk '{print $2}')
    if [[ -n "$mouse_status" ]]; then
        if [[ "$mouse_status" == "true" ]]; then
            return 1  # Disabled
        else
            return 0  # Enabled
        fi
    fi

    # Check in general device list
    local status=$(hyprctl devices | grep -A 10 "$device" | grep -i "disabled" | awk '{print $2}')
    if [[ "$status" == "true" ]]; then
        return 1  # Disabled
    else
        return 0  # Enabled
    fi
}

# Function to toggle touchpad
toggle_touchpad() {
    local device="$1"

    if is_touchpad_enabled "$device"; then
        # Disable touchpad
        hyprctl keyword device:"$device":enabled false
        notify-send -t $NOTIFICATION_TIMEOUT "Touchpad" "Touchpad disabled" -i input-touchpad
        echo "Touchpad disabled"
    else
        # Enable touchpad
        hyprctl keyword device:"$device":enabled true
        notify-send -t $NOTIFICATION_TIMEOUT "Touchpad" "Touchpad enabled" -i input-touchpad
        echo "Touchpad enabled"
    fi
}

# Function to show touchpad status
show_status() {
    local device="$1"

    if is_touchpad_enabled "$device"; then
        notify-send -t $NOTIFICATION_TIMEOUT "Touchpad" "Touchpad is currently enabled" -i input-touchpad
        echo "Touchpad is enabled"
    else
        notify-send -t $NOTIFICATION_TIMEOUT "Touchpad" "Touchpad is currently disabled" -i input-touchpad
        echo "Touchpad is disabled"
    fi
}

# Main logic
main() {
    # Check if hyprctl is available
    if ! command -v hyprctl &> /dev/null; then
        echo "Error: hyprctl not found. Make sure you're running Hyprland."
        exit 1
    fi

    # Check if notify-send is available
    if ! command -v notify-send &> /dev/null; then
        echo "Warning: notify-send not found. Notifications will not work."
    fi

    # Find touchpad device
    if [[ -z "$TOUCHPAD_DEVICE" ]]; then
        TOUCHPAD_DEVICE=$(find_touchpad)
        if [[ -z "$TOUCHPAD_DEVICE" ]]; then
            echo "Error: No touchpad device found."
            notify-send -t $NOTIFICATION_TIMEOUT "Touchpad" "No touchpad device found" -i dialog-error
            exit 1
        fi
    fi

    echo "Using touchpad device: $TOUCHPAD_DEVICE"

    # Handle command line arguments
    case "${1:-toggle}" in
        "toggle")
            toggle_touchpad "$TOUCHPAD_DEVICE"
            ;;
        "enable")
            hyprctl keyword device:"$TOUCHPAD_DEVICE":enabled true
            notify-send -t $NOTIFICATION_TIMEOUT "Touchpad" "Touchpad enabled" -i input-touchpad
            echo "Touchpad enabled"
            ;;
        "disable")
            hyprctl keyword device:"$TOUCHPAD_DEVICE":enabled false
            notify-send -t $NOTIFICATION_TIMEOUT "Touchpad" "Touchpad disabled" -i input-touchpad
            echo "Touchpad disabled"
            ;;
        "status")
            show_status "$TOUCHPAD_DEVICE"
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [toggle|enable|disable|status|help]"
            echo "  toggle  - Toggle touchpad on/off (default)"
            echo "  enable  - Enable touchpad"
            echo "  disable - Disable touchpad"
            echo "  status  - Show current touchpad status"
            echo "  help    - Show this help message"
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use '$0 help' for usage information."
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
