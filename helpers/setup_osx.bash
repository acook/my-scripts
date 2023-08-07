#!/usr/bin/env bash

# install Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# install the fun stuff with Homebrew
brew install \
  brew-cask \
  reattach-to-user-namespace --wrap-launchctl --wrap-pbcopy-and-pbpaste \
  mobile-shell ssh-copy-id autossh \
  coreutils findutils --default-names  moreutils colordiff renameutils \
  sift \
  tmux bash zsh \
  ctags macvim --override-system-vim html2text \
  git --with-brewed-curl --with-gettext --with-pcre

# Install some GUI apps with Brew Cask
brew cask install \
  xquartz tinkertool \
  google-chrome firefox \
  alfred caffeine f-lux spectacle \
  iterm2 github sequel-pro \
  mou

# Link Cask apps to Alfred search path
brew cask alfred link
