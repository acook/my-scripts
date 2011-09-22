#!/usr/bin/env ruby
#

output = "Success"

gems = `gem list | cut -d" " -f1`.split("\n")

#puts "gems: ", gems

gems.each do |g|
  puts "## uninstalling: #{g}"
  puts `gem uninstall -aIx #{g}`
end
