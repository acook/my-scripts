#!/usr/bin/ruby

class Git
  # include this module to get access to its methods
  module Methods
    def git command, options = []
      `git #{command} #{Git.parse_options(options)}`
    end
  end

  class << self
    def parse_options options
    end
  end
end


puts ARGV

@command = ARGV.shift

# if any arg starts with two dashes and is immediately followed by an alphanumeric
# then move it to our options array.
ARGV. { |arg, index| @options << ARGV.delete(index) if arg =~ /$--\a/ }

    #p @branch -- source @source = 'origin'

git pull :no_ff @source @branch
