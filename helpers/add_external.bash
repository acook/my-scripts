#!/usr/bin/env bash

set -e

URI="$1"

cd "$(git root)/external/"
git submodule add "$URI"

