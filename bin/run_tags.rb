#!/usr/bin/env ruby

# A script to run ctags on all .rb files in a project. Can be run on
# the current dir, called from a git callback, or install itself as a
# git callback.

require 'pathname'

CTAGS = %x{which ctags}.chomp
HOOKS = %w{ post-merge post-commit post-checkout }
HOOKS_DIR = '.git/hooks'

def install
  if !File.writable?(HOOKS_DIR)
    $stderr.print "The install option [-i] can only be used within a git repo; exiting.\n"
    exit 1
  end

  HOOKS.each { |hook| install_hook("#{HOOKS_DIR}/#{hook}") }
end

def run_tags(dir, run_in_background = false)
  if File.executable?(CTAGS) and File.writable?(dir) then
    cmd = Array.new
    cmd << "find #{dir} -name \\\*.rb | #{CTAGS} -f #{dir}/tags -L -"
    cmd << '2>>/dev/null' unless $VERBOSE
    cmd << '&' if run_in_background && !$VERBOSE
    cmd = cmd.join ' '
    puts cmd if $VERBOSE
    system cmd
  else
    unless File.executable? CTAGS then
      warn "FATAL : ctags not found"
    end
    unless File.writable? dir then
      warn "FATAL : directory `#{dir}' not writable"
    end
  end
end

def install_hook(hook)
  if File.exists?(hook)
    $stderr.print "A file already exists at #{hook}, and will NOT be replaced.\n"
    return
  end

  print "Linking #{__FILE__} to #{hook}\n"
  %x{ln -s #{__FILE__} #{hook}}
end

if ARGV.first == '-i'
  install
else
  puts 'running tags..' if $VERBOSE
  run_tags Dir.pwd #, HOOKS.include?(File.basename(__FILE__))
end
