#!/usr/bin/env bash

set -e

URI="$1"

git submodule add "$URI" "$(git root)/external/"

