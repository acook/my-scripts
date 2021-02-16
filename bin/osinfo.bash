#!/usr/bin/env bash

# Gather uname
UNAME=$(uname)

# Detect platform
case $UNAME in
  Darwin)        # OS X
    PLATFORM='osx'
  ;;

  Linux)         # Linux
    PLATFORM='linux'

    # Gather release info
    if [[ -n `command -v lsb_release` ]]; then
      # dump release info and drop version
      RELEASE=`lsb_release -ds 2>/dev/null | sed 's/^\(.*\) .*/\L\1/'`
    else
      # grab first entry and remove extraneous path and filename affixes
      RELEASE=`echo /etc/*release | head -1 | sed 's:/etc/\(.*\)-release:\1:'`
    fi

    # Detect distro
    case $RELEASE in
      ubuntu)
        DISTRO='ubuntu'
        ;;

      gentoo)
        DISTRO='gentoo'
        ;;

      \"Solus\")
        DISTRO='solus'
        ;;

      *)
        echo 'Unknown distro' $RELEASE >&2
        exit 2
        ;;
    esac
    ;;
  *)
    echo 'Unknown platform' $UNAME >&2
    exit 1
    ;;
esac

# so this can be sourced as a library
export DISTRO
export PLATFORM

if [[ $1 == "-w" ]]; then
  echo $PLATFORM $DISTRO
else
  echo $PLATFORM
  echo $DISTRO
fi
