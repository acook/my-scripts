#!/usr/bin/env bash

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

USERNAME=$(whoami)
STEAMNULLSINK_HOME="/home/$USERNAME/workspace/steam-null-sink"
STEAM_HOME="/home/$USERNAME/.steam"

tail -n 0 -F $STEAM_HOME/steam/logs/streaming_log.txt |
    grep --line-buffered 'Streaming started to Steam Link' |
    while read; do
        DEFAULT_SINK=$(pacmd info |
        awk -F ":" '/Default sink name:/ {print $2}')
        
        if [[ $DEFAULT_SINK != " steamNullSink" ]]; then
            echo "$DEFAULT_SINK" > $STEAMNULLSINK_HOME/default-sink.backup
        fi
        
        $STEAMNULLSINK_HOME/switch-sink.sh steamNullSink
    done
