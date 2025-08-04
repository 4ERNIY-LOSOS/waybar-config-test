#!/bin/bash
# A script to select a new default audio sink using rofi

# Check for jq
if ! command -v jq &> /dev/null
then
    # This is a silent fail, maybe not the best, but won't crash waybar
    exit
fi

# Get available sinks and format them for rofi
sinks=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Audio/Sink") | .info.props."node.description"')

# Present the sinks in rofi and get the user's choice
chosen_sink=$(echo -e "$sinks" | rofi -dmenu -p "Select Audio Output")

# If the user made a choice, find the corresponding sink ID and set it as default
if [ -n "$chosen_sink" ]; then
    sink_id=$(pw-dump | jq -r --arg chosen_sink "$chosen_sink" '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Audio/Sink" and .info.props."node.description" == $chosen_sink) | .id')
    if [ -n "$sink_id" ]; then
        wpctl set-default "$sink_id"
    fi
fi
