#!/bin/bash

# Define profile names
quiet_profile='Quiet'
balan_profile='Balanced'
perfo_profile='Performance'

# Check if asusctl command is available
if ! command -v asusctl &> /dev/null; then
    echo "Error: asusctl command not found. Make sure it is installed." >&2
    exit 1
fi

# File to store the last active profile
last_active_profile_file="/tmp/last_active_profile"

# Check if the file exists and is not empty
if [ -s "$last_active_profile_file" ]; then
    last_active_profile=$(cat "$last_active_profile_file")
else
    # Set a default profile if the file doesn't exist or is empty
    last_active_profile="$quiet_profile"
fi

# Get the current profile
cur_profile=$(asusctl profile -p | awk '{print $4}')

# Check if the profile has changed
if [ "$cur_profile" != "$last_active_profile" ]; then
    case "$cur_profile" in
        "$quiet_profile")
            dunstify "Switched to Quiet profile" -t 2000
            ;;
        "$balan_profile")
            dunstify "Switched to Balanced profile" -t 2000
            ;;
        "$perfo_profile")
            dunstify "Switched to Performance profile" -t 2000
            ;;
        *)
            dunstify "Unknown profile: $cur_profile" -t 2000
            ;;
    esac

    # Update the last_active_profile
    echo "$cur_profile" > "$last_active_profile_file"
fi

# Output the current profile (optional)
echo "$cur_profile"

