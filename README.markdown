# ACOOK's Script Repository

This a big collection of scripts and simple tools that I've written over the years.
There are also some useful scripts which I am not the original author of.

It also includes some additional git modules for other tools others or I have written.

Most scripts use `bash` or `ruby` with a couple that use `perl`, or `zsh`.

# Installation

The installer script will create symlinks to `~/bin` and `~/xbin` then pull down other repos specified in `.gitmodules`.

```shell
  ./install
```

## Optional

There are additional setup scripts in `./scripts/` for other quick setup options.

## Included Tools

ccat
----

cat with syntax highlighting

depends on either:

- pygmentize
  - python

OR

- rouge
  - ruby

run\_tags.rb
-----------

installs hooks into a git repo that runs ctags when you push, pull, commit, merge, or change branches

depands on:

- ruby
- ctags
- git

