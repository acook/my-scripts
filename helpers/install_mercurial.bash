#!/bin/bash

cd `dirname $0`/external

echo setting up mercurial...
sudo easy_install pip
sudo pip install Mercurial
sudo pip install hg-git
sudo pip install Pygments
hg clone https://bitbucket.org/durin42/hg-git
hg clone https://bitbucket.org/sjl/hg-prompt
hg clone https://bitbucket.org/tksoh/hgshelve


