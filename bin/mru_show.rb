#!/usr/bin/env ruby

if %w{--help -h -?}.include? ARGV.first then
  puts 'mru_show - show the most recently used files from GTK'
  puts
  puts 'This will automatically find the GTK MRU data and display the list of files.'
  puts 'You can also pipe a file to it, as there may be multiple older older MRU files in the same directory.'
  exit
end

if ARGV.include? '--noheader' then
  noheader = true
else
  noheader = false
end

require 'pathname'

def datapath
  dp = ENV['XDG_DATA_HOME']

  if !dp || dp.empty? then
    dp = "#{ENV['HOME']}/.local/share"
  end

  dp = Pathname.new dp

  puts 'datapath does not exist' unless dp.exist?
  puts 'datapath not a dir' unless dp.directory?

  dp
end

if $stdin.tty? then
  mrufile = datapath.join 'recently-used.xbel'
  if mrufile.exist? then
    infile = mrufile.open
  else
    puts "\e[31mno GTK MRU file found at: #{mrufile}\e[0m"
    exit 1
  end
else
  infile = $stdin
end


lines = infile.readlines

@gtk = 0
lines.each do |line|
  m = line.match(/file:\/\/(.*?)"/)
  if m then
    if @gtk == 0 then
      puts "\e[34m# GTK MRU:\e[0m" unless noheader
    end

    @gtk += 1
    puts m.captures.first.gsub(/^#{ENV['HOME']}/, '~')
  end
end

rd = datapath.join 'RecentDocuments'

@generic = 0
rd.each_child do |f|
  pf = Pathname.new f
  next unless pf.file?
  pf.readlines.each do |line|
    m = line.match /^URL.*?=(.*)/
    if m then
      if @generic == 0 then
        puts "\e[33m# Generic MRU:\e[0m" unless noheader
      end

      @generic += 1
      puts m.captures.first.gsub /^#{ENV['HOME']}/, '~'
    end
  end
end

puts "\n\e[36m# #{@generic + @gtk} MRU files found in total\e[0" unless noheader
