#!/usr/bin/env zsh

source ~/bin/prompt_helpers

# update window title with directory
function precmd {
  set_window_title $PWD;
}

# update window title with command
function preexec {
  commandline="$1" # the user-entered commandline is passed in as first arg
  args=${${(z)commandline}[2,-1]} # get command's args
  new_title=${args:-$PWD} # if no args, then use the pwd
  set_window_title $new_title
}
