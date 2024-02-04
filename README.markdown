# Script Repository

This a big collection of scripts and simple tools that I've written over the years, it also includes submodules to other scripts. First moved into `git` in 2010 but with a prehistory going back to at least 2006.

All scripts use either `bash` or `ruby` unless otherwise indicated.

# Installation

```shell
  ./install
```

The installer script will create symlinks to `~/bin` and `~/xbin` then pull down other repos specified in `.gitmodules`.

## Included Tools

| Script | Description |
| ---- | ---- |
| ccat | Colorized `cat` which detects and uses one of several colorizers and falls back to plain text |
| common_factors | Find all the common factors among an arbitrarily long list of inputs |
| d | Simple dice roller, shows each dice pool in a separate table `5d6 1d20`  with each result and the total |
| diealot | A kill script which attempts to give a process a chance to exit gracefully, using stronger measures with silly output for each step |
| fdls | List all processes with their number of open file descriptors (may take a while) |
| get | Wrapper around `curl`/`wget` with sane defaults to make them behave similarly and display result in terminal, used by other `get*` scripts |
| getip | Shows current machine's IP as seen from an external service, may return IPv6 or IPv4 |
| git-author | Git subcommand to rewrite the author name and info on past commits, used to fix incorrect email addresses |
| git-children-of | Git subcommand to display the children of a given commit |
| git-dates | Git subcommand to display the dates of the most recent commits for each branch in a repo |
| mass_rm | Delete all files from a list in specified file which match a grep pattern |
| newest | Finds the newest binary in a path and runs it, handy when generating a lot of builds in one folder |
| orphanage | Lists all untracked files from a directory, useful for running in a directory to see if it contains non-git subfolders or git repos with files that have yet to be committed |
| recite | Using Piper TTS it will read input text out to your default audio device |
| remove_trailing_whitespace | Removes the trailing whitespace from files |
| retry | Rerun any command until it succeeds |
| sdtest | A quick hack to test if an SD card or other storage drive is fake or failing, only use if `f3` is unavailable |
| snr | A quick and dirty way to do a search and replace on all the files in a directory using perl regex |
| sudeploy | Login as a user that has no shell or is set `nologin` |
| system-clipboard | Script which interacts with the system clipboard on MacOS and Xwindows |
| tmux-resume | Sets up a `tmux` session and automatically resumes it if present, will set up integration with iTerm if available |
| ttscleaner | Removes unnecessary newlines and bracketed citations that often pepper academic papers to make for smoother TTS reading |
| wacom-touch | Directly set the trackpad functionality of a Wacom tablet |
| wacom-touch-toggle | Toggle the trackpad functionality of a Wacom tablet |
| wacom-wrapper | Wraps the `xsetwacom` tool and provides status and error handling |
| watcher | Continually reports on the presence of processes by name or attribute |
| whatkind | Prints all of the files in the current directly with different colors based on their detected `libmagic` `file` type, the simple Ruby predecessor to `acook/lister` |
| winekill | Kill all processes running with a given WINE path |
| yt | Download video from sites using `yt-dlp` |
| hex_to_ansi.rb | Convert hex RGB to ANSI codes |
| run_tags.rb | A script to run ctags on all `.rb` files in a project, can install git hooks to do the same |

### MacOS Scripts

Scripts that are only known to work on MacOS.

| Script | Description |
| ---- | ---- |
| dns | Quickly swap between DHCP and various public DNS servers on MacOS from the commandline |
| inpkg | Helper script to use MacOS installers from the commandline |
| locatedb | Little more than a reminder for how to update the Locate DB on MacOS |
| macos_unlock_network_pane | Unlocks the network pane in MacOS settings, useful in case of a rogue system policy or other issues |
| runsys | A weird abuse of the shebang line which only works on MacOS |
| safe-reattach-to-user-namespace | Runs `reattach-to-user-namespace` if available, and just runs the provided command directly if not, only useful on particular combinations of MacOS and `tmux`/`screen` due to some weird quirk of the OS |
| sockmonkey | Set up a SOCKS tunnel over SSH for browsers to proxy through, only works on MacOS |

### Weirdly Specific

These might be specific to my setup or rarely useful to others.

| Script | Description |
| ---- | ---- |
| wacom-blender | A Wacom tablet configuration for Blender |
| wacom-krita | A Wacom tablet configuration for Krita |
| wacom-setup | A Wacom tablet configuration starting point |
| testtable.bash | Prints a truth table to show how different tests work |
| colortable | Print out the 16 basic ANSI colors and the rest of the 256 color palette |
| rcolor | A Ruby script which displays a 256 color table, it is faster than `colortable` |
| bashrgb | A set of simple bash functions for basic terminal styling |
| prompt_helpers | A sort of reference table of bash functions often interesting to writing shell prompts |
| mdcontent | Display content of all markdown files in a directory, ignoring frontmatter, intended to be used for compiling stats |
| resync | Rsync wrapper with retries, uses environment variables for configuration |
| anorm | Normalize the volume of an audio file |
| avmerge | Combine an audio file into a video file |
| avmergenorm | Normalize an audio file and combine it with a video file, uses `anorm` and `avmerge` |
| csig | Display a sorted list of the C/C++ function signatures for a given list or directory of files |
| uninstall_all_gems | Uninstall all Ruby gems in the current environment, as a backup for if `gem uninstall -aIx` on its own isn't working |
| gg | A manager for `Go`'s `GOPATH` environment variable which can easily isolate multiple `Go` source trees, similar to a virtual environment in Python or a gemset in Ruby, also works as a library to be included in other bash scripts |

### WIP/Outdated Scripts

These may be broken or are otherwise only still here as a reminder to myself.

| Script | Description |
| ---- | ---- |
| calcdie | **WIP** Dice Expression Parser, can write like `5d5 + 4d2` and it will roll the dice and add them together for you |
| editcode | **WIP** intended to identify which code editors are available and usable in the current environment and launch the best one |
| gimme | **WIP** similar to `get` but was supposed to invoke the download on a remote server, compress the file, and then transfer it, for bandwidth limited localhosts |
| group_hash_db | **WIP** Sketch of an in-memory store |
| neuvo_prompt | **WIP** Old bash prompt |
| dl.rb | **WIP** Simple download manager |
| stringmanip.zsh | **WIP** String manipulation examples in ZSH |
| git_prompt | An old script for a git-aware bash prompt |
| hg_prompt | An old Mercurial-aware bash prompt |
| xeiprompt | Yet another bash prompt |
| dl | Wrapper for `curl` to download a list of files and retry failures with some additional helpers, possibly obsolete with newer versions of curl having most of these features? |
| rails_helpers | A pile of aliases and functions to simplify common tasks when doing Rails development (possibly outdated) |
| vbox_update | Automate upgrading VirtualBox (possibly no longer working?) |
| qube | An old script to set up Kubernetes locally with RabbitMQ |
| ytav | Downloads audio and video separately then normalizes the audio and combines them into one, uses `yt`, `avnorm` |
| window_title.zsh | ZSH script to set the terminal window title |
| ecal | Calculates the output voltage of a voltage divider given its input voltage and the rating of its resistors |
| getipinfo | Shows a little more detail about current host's connection |

