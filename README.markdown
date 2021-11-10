# Script Repository

This a big collection of scripts and simple tools that I've written over the years.
There are also some useful scripts which I am not the original author of.

It also includes some additional git modules for other tools others or I have written.

Most scripts use `bash` or `ruby` with a couple that use other scripting languages and even 1 rogue binary I keep because I can't figure out where it came from...

# Installation

```shell
  ./install
```

The installer script will create symlinks to `~/bin` and `~/xbin` then pull down other repos specified in `.gitmodules`.

## Optional

There are additional setup scripts in `./scripts/` for other quick setup options.

## Included Tools

ccat
----

`cat` with colors!

depends on either `python`/`Pygments` or `ruby`/`rouge` for the syntax highlighting

run\_tags.rb
-----------

installs hooks into a `git` repo that runs `ctags` when you push, pull, commit, merge, or change branches

depends on `ruby` and `ctags` (and of course `git`)
