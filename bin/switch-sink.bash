#!/usr/bin/env bash

case "${1:-}" in
  (""|list)
    pacmd list-sinks |
      grep -E 'index:|name:'
    ;;
  ([a-zA-Z0-9_.-]*)
    echo switching default
    pacmd set-default-sink $1 ||
      echo failed
    echo switching applications
    pacmd list-sink-inputs |
      awk '/index:/{print $2}' |
      xargs -r -I{} pacmd move-sink-input {} $1 ||
        echo failed
    echo switching steam recorder to monitor this source
    pacmd list-source-outputs |
      tr '\n' '\r' |
      perl -pe 's/.*? *index: ([0-9]+).+?application\.process\.binary = "([^\r]+)"\r.+?(?=index:|$)/\2:\1\r/g' |
      tr '\r' '\n'|
      awk -F ":" '/steam/ {print $2}'|
      xargs -r -I{} pacmd move-source-output {} $1.monitor ||
        echo failed
    ;;
  (*)
    echo "Usage: $0 [|list|<sink name to switch to>]"
    ;;
esac
