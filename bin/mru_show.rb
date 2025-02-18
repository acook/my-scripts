#!/usr/bin/env ruby

require 'pathname'
require 'stringio'

class MRU
  def initialize noheader: false
    @noheader = noheader
  end

  def usage
    puts 'mru_show - show the most recently used files from multiple sources'
    puts
    puts "\t--noheader\thide headers that say the source of the file"
    puts
    puts "sources:"
    puts
    puts "\tGTK\t#{gtkfile false}"
    puts "\tKrita\t#{kritafile}"
    puts "\tVLC\t#{vlcfile}"
    puts "\tgeneric\t#{genericpath}"
    puts
    puts 'This will automatically find the GTK MRU data and display the list of files.'
    puts 'You can also pipe a file to it, as there may be multiple older GTK MRU files in the same directory.'
  end

  def run
    gtk
    krita
    vlc
    generic

    report
  end

  def gtkfile open = true
    mrufile = datapath.join 'recently-used.xbel'
    return mrufile unless open

    # no tty means something is being piped in
    # we assume this is a GTK file and use it instead
    return $stdin unless $stdin.tty?

    if mrufile.exist? then
      mrufile.open
    else
      # if can't find the MRU file then we can report it
      warn "\e[31mno GTK MRU file found at: #{mrufile}\e[0m" unless @noheader
      # stub it out so the loop will skip it
      StringIO.new
    end
  end

  def gtk
    lines = gtkfile.readlines

    lines.each do |line|
      m = line.match(/file:\/\/(.*?)"/)
      if m then
        mru :gtk, 'GTK', m.captures.first
      end
    end
  end

  def genericpath
    datapath.join 'RecentDocuments'
  end

  def generic
    genericpath.each_child do |f|
      pf = Pathname.new f

      # skip directories
      next unless pf.file?

      # extract the URL from each file
      pf.readlines.each do |line|
        m = line.match /^URL.*?=(.*)/
        if m then
          mru :generic, 'generic', m.captures.first
        end
      end
    end
  end

  def kritafile
    configpath.join 'kritarc'
  end

  def krita
    kritafile.open.readlines.each do |line|
      m = line.match /^Name\d*=(.*)/
      if m then
        mru :krita, 'Krita', m.captures.first
      end
    end
  end

  def vlcfile
    configpath.join 'vlc', 'vlc-qt-interface.conf'
  end

  def vlc
    list = vlcfile.read.match /\[RecentsMRL\]\nlist=(.*?)\n/m

    # VLC doesn't consistantly quote filenames, so splitting on commas is perilous
    # i don't feel like writing a parser, so i am splitting on the protocol portion
    # this includes http:// and file:// which are unlikely to appear in filenames
    list.captures.first.split(/\w+:\/\//).each do |f|
      # VLC uses a weird serialization format and this is basically null/empty set
      break if f == '@Invalid()'

      # cleanup any quotes or commas
      cf = f.gsub(/^"|"$/, '').gsub(/, $/, '')
      # there may be stray leading quote in the very first position, so we skip it
      next if cf == ""

      mru :vlc, 'VLC', cf
    end if list
  end

  def report
    puts "\n\e[36m# #{count.values.sum} MRU files found in total\e[0m" unless @noheader
  end

  def mru key, name, file
    if count[key] then
      count[key] += 1
    else
      count[key] = 0
      puts "\e[34m# #{name}:\e[0m" unless @noheader
    end
    puts unex file
  end

  def count
    @count ||= {}
  end

  # expand tilde to save space and make paths more readable
  def unex path
    path.gsub /^#{ENV['HOME']}/, '~'
  end

  def datapath
    xdgpath 'XDG_DATA_HOME', '.local/share'
  end

  def configpath
    xdgpath 'XDG_CONFIG_HOME', '.config'
  end

  def xdgpath env, fallback
    path = ENV[env]

    if !path || path.empty? then
      path = "#{ENV['HOME']}/#{fallback}"
    end

    pn = Pathname.new path

    puts 'datapath does not exist' unless pn.exist? || @noheader
    puts 'datapath not a dir' unless pn.directory?  || @noheader

    pn
  end
end

if ARGV.include? '--noheader' then
  noheader = true
else
  noheader = false
end

mru = MRU.new(noheader: noheader)

if !(%w{--help -h -?} & ARGV).empty? then
  mru.usage
  exit
end

mru.run

