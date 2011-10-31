#!/bin/bash

echo setting up mercurial...
sudo easy_install pip
sudo pip install Mercurial
mkdir ~/Pork
cd ~/Pork
sudo easy_install hg-git
hg clone https://bitbucket.org/durin42/hg-git
hg clone https://bitbucket.org/sjl/hg-prompt
hg clone https://bitbucket.org/tksoh/hgshelve


