#!/usr/bin/env python3
"""
A robust script to fetch KDE Connect status for Waybar by parsing text output.
This version is compatible with older kdeconnect-cli releases without the --json flag.
"""
import json
import re
import subprocess
import sys
from typing import Dict, List, Optional


def get_battery_icon(percentage: int, is_charging: bool = False) -> str:
    """Returns a battery icon based on the percentage and charging status."""
    if is_charging:
        return "󰂄"  # charging
    if percentage > 95:
        return "󰁹"  # full
    if percentage > 80:
        return "󰂂"
    if percentage > 60:
        return "󰂁"
    if percentage > 40:
        return "󰁿"
    if percentage > 20:
        return "󰁽"
    return "󰁻"  # alert


def get_device_battery(device_id: str) -> Optional[Dict]:
    """Fetches battery information for a single device by parsing text."""
    try:
        battery_output = subprocess.check_output(
            ["kdeconnect-cli", "-d", device_id, "--battery"],
            text=True,
            stderr=subprocess.DEVNULL,
            timeout=2,
        ).strip()

        # Example output: "- OnePlus 9: 69% (Charging)"
        match = re.search(r"(\d+)%", battery_output)
        if match:
            return {
                "charge": int(match.group(1)),
                "is_charging": "Charging" in battery_output,
            }
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return None
    return None


def get_all_devices() -> List[Dict]:
    """Parses `kdeconnect-cli -l` output to get a list of all devices."""
    try:
        list_output = subprocess.check_output(
            ["kdeconnect-cli", "-l"], text=True, stderr=subprocess.PIPE
        ).strip()
    except FileNotFoundError:
        # This special return indicates the program isn't installed.
        raise

    devices = []
    # Regex to capture: "- Device Name: device_id (status)"
    device_regex = re.compile(r"^- (.+?):\s*([a-f0-9_-]+)\s*\((.+?)\)")
    for line in list_output.split("\n"):
        match = device_regex.match(line.strip())
        if match:
            name, dev_id, status = match.groups()
            devices.append(
                {
                    "name": name.strip(),
                    "id": dev_id,
                    "is_reachable": "reachable" in status,
                }
            )
    return devices


def get_status_output() -> Dict:
    """Generates the final JSON output for Waybar."""
    try:
        all_devices = get_all_devices()
    except FileNotFoundError:
        return {"text": "󰂲", "tooltip": "KDE Connect not found", "class": "error"}

    if not all_devices:
        return {
            "text": "󰂲",
            "tooltip": "KDE Connect: No devices paired",
            "class": "disconnected",
        }

    reachable_devices = [d for d in all_devices if d["is_reachable"]]

    if not reachable_devices:
        tooltip = "KDE Connect: No device connected"
        paired_names = ", ".join([d["name"] for d in all_devices])
        tooltip += f"\nPaired: {paired_names}"
        return {"text": "󰂲", "tooltip": tooltip, "class": "disconnected"}

    # Enrich all reachable devices with battery info
    for device in reachable_devices:
        battery_info = get_device_battery(device["id"])
        if battery_info:
            device.update(battery_info)

    primary_device = reachable_devices[0]

    # Build the main text for the bar
    if "charge" in primary_device:
        icon = get_battery_icon(
            primary_device["charge"], primary_device.get("is_charging", False)
        )
        text = f'{icon} {primary_device["charge"]}%'
    else:
        text = f' {primary_device["name"]}'

    # Build the comprehensive tooltip
    tooltip_lines = []
    for device in reachable_devices:
        line = f"<b>{device['name']}</b>"
        if "charge" in device:
            status = " (Charging)" if device.get("is_charging") else ""
            line += f": {device['charge']}%{status}"
        else:
            line += ": Connected"
        tooltip_lines.append(line)

    tooltip = "\n".join(tooltip_lines)

    return {"text": text, "tooltip": tooltip, "class": "connected"}


if __name__ == "__main__":
    try:
        status = get_status_output()
        print(json.dumps(status))
    except Exception as e:
        print(
            json.dumps(
                {
                    "text": "󰂲",
                    "tooltip": f"Critical script failure: {e}",
                    "class": "error",
                }
            )
        )
        sys.exit(1)
