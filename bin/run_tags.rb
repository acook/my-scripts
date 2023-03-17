#!/usr/bin/env ruby

# A script to run ctags on all .rb files in a project. Can be run on
# the current path, called from a git hook, or install itself as a
# git hook.

require 'pathname'

CTAGS = Pathname.new %x{which ctags}.chomp
HOOKS = %w(post-merge post-commit post-checkout)
HOOKS_PATH = Pathname.new '.git/hooks'
THIS = Pathname.new(__FILE__)
TAGFILE = 'tags'

# this module has functions which aren't use-case specific
module Utils
  def gitroot path
    result = run %Q(cd "#{path}" && git rev-parse --show-toplevel), quiet: true, error: false
    if result[:success]
      Pathname.new result[:output]
    else
      nil
    end
  end

  def err msg, color: 41
    warn "\e[#{color}m#{msg}\e[0m"
  end
  
  def say msg, color: 38
    puts "\e[#{color}m#{msg}\e[0m"
  end

  def run cmd, quiet: false, error: true, noreturn: false
    say "Running command:\e[0m #{cmd}", color: 35 unless quiet
  
    if noreturn then
      # this will terminate the Ruby script and run whatever command instead
      # this is useful so that Ruby doesn't sit around waiting for the command to exit when you want it to be backgrounded anyway
      # could also be done with like fork, exec, detatch, etc but this is simpler and faster #
      exec cmd
      exit 0 # unreachable code, just here to make it super clear what is happening
    end

    h = Hash.new
    h[:cmd] = cmd
    h[:output] = %x{#{cmd}}.chomp
    h[:status] = $?.exitstatus
    h[:success] = h[:status] == 0
  
    unless quiet
      if h[:output] && !h[:output].empty?
        msg = h[:output]
      else
        msg = nil
      end
    
      if h[:success] then
        color = 32
        msg ||= "{command succeeded}"
      else
        color = 31
        msg ||= "{command failed}"
      end
  
      say ">\e[0m #{msg}", color: color
    end
  
    if error && !h[:success] then
      # raise error to make it easier to debug when things go wrong
      # otherwise you will just see cryptic "sh: error" with no idea what casued it
      raise StandardError, %Q(Command "#{cmd}" exited with non-zero status #{h[:status]} and produced "#{h[:output]}".) 
    end
  
    h
  end
end

# the meat and potatoes
class Tags
  include Utils

  def usage status=0
    puts <<-EOF
      #{THIS.basename} [-i|-g] : run ctags and install git hooks

      -g\t-\tGenerates tags files for Ruby files. (default action)
      -i\t-\tInstall hooks. The install option can only be used within a git repo.
      -h\t-\tHelp and usage info. (you're looking at 'em)
    EOF
    exit status
  end

  def install
    say 'Starting git hook installation..', color: 32
    unless HOOKS_PATH.writable? then
      err "FATAL : destination path #{HOOKS_PATH} not writable"
      usage 1
    end

    HOOKS.each { |hook| install_hook hook }
  end

  def generate_tags path
    $VERBOSE = true unless am_hook? # if we are being run directly, then set verbose, otherwise, respect the existing setting

    say 'Starting tag generation..', color: 32 if $VERBOSE
    tagpath = Pathname.new path
    tagfile = tagpath.join TAGFILE
    
    unless CTAGS.executable? then
      err "FATAL : ctags not found"
      exit 2
    end
    
    unless tagpath.writable? then
      err %Q(FATAL : target path "#{tagpath}" not writable)
      exit 3
    end

    root = gitroot path # automatically uplevel and run ctags at the root of the git repo if it finds one

    cmd = Array.new
    cmd << %Q(cd "#{root}" &&) if root
    cmd << %Q(\\find "#{tagpath}" -name \\\*.rb | #{CTAGS} -f "#{tagfile}" -L -)
    cmd << '2>>/dev/null' unless $VERBOSE
    cmd << '&' unless $VERBOSE # also runs it in background so it doesn't slow down git commands
    cmd = cmd.join ' '

    run cmd, noreturn: true
  end

  def install_hook hook
    hook_file = HOOKS_PATH.join hook

    if hook_file.exist? then
      if hook_file.symlink? then
        err %Q(WARN : Found symlink to "#{hook_file.readlink}", replacing it...), color: 31
        run %Q(rm -v #{hook_file})
      else
        err %Q(ERROR : A file already exists at "#{hook_file}", and will NOT be replaced.)
        return
      end
    end

    unless root = gitroot('.') then
      err "FATAL : Must be installed in a git repo!"
      usage 4
    end

    run %Q(cd #{root} && \\ln -s -v #{THIS} #{hook_file})
  end

  def am_hook?
    HOOKS.include? THIS.basename.to_s
  end

  def self.parse_args_and_do_stuff args
    me = self.new
    if args.first == '-g' || args.size == 0 then
      path = Pathname.pwd

      me.generate_tags path
    elsif args.first == '-i' then
      me.install
    elsif args.include? '-h' then 
      me.usage
    elsif me.am_hook? # git can send a variey of random arguments to hooks, so just roll with whatever gets passed in
      #p args if args && !args.empty? # for the curious
      path = Pathname.pwd
      me.generate_tags path
    else
      me.usage
    end
  end
end

Tags.parse_args_and_do_stuff ARGV
