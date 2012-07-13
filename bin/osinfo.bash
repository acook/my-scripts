# Detect platform
UNAME=$(uname)
case $UNAME in
  Darwin)        # OS X
    export PLATFORM='osx'
  ;;

  Linux)         # Linux
    export PLATFORM='linux'

    # Detect distro
    if [[ -n `command -v lsb_release` ]]; then
      RELEASE=`lsb_release -ds 2>/dev/null | sed 's/^\(.*\) .*/\L\1/'`
    else
      RELEASE=`echo /etc/*release | head -1 | sed 's:/etc/\(.*\)-release:\1:'`
    fi

    # detect distro
    case $RELEASE in
      ubuntu)
        export DISTRO='ubuntu'
        ;;

      gentoo)
        export DISTRO='gentoo'
        ;;
    esac
    ;;
esac

echo $PLATFORM $DISTRO
