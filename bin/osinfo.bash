#!/usr/bin/env bash

# Gather uname
UNAME=$(uname)

# Detect platform
case $UNAME in
  Darwin)        # OS X
    export PLATFORM='osx'
  ;;

  Linux)         # Linux
    export PLATFORM='linux'

    # Gather release info
    if [[ -n `command -v lsb_release` ]]; then
      # dump release info and drop version
      RELEASE=`lsb_release -ds 2>/dev/null | sed 's/.*/\L/'`
    else
      # grab first entry and remove extraneous path and filename affixes
      RELEASE=`echo /etc/*release | head -1 | sed 's/.*/\L/'`
    fi

    # Detect distro
    case $RELEASE in
      ubuntu)
        export DISTRO='ubuntu'
        ;;

      gentoo)
        export DISTRO='gentoo'
        ;;

      *)
        echo 'Unknown distro' $RELEASE
        exit 2
        ;;
    esac
    ;;

  *)
    echo 'Unknown platform' $UNAME
    exit 1
    ;;
esac

echo $PLATFORM $DISTRO | sed 's/ /\n/'
