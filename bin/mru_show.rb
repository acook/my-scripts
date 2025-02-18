#!/usr/bin/env ruby

require 'pathname'
require 'stringio'

class MRU
  def initialize noheader: false
    @noheader
  end

  def usage
    puts 'mru_show - show the most recently used files from multiple sources'
    puts
    puts "\t--noheader\thide headers that say the source of the file"
    puts
    puts "sources:"
    puts
    puts "\tGTK\t#{gtkfile false}"
    puts "\tgeneric\t#{genericpath}"
    puts "\tKrita\t#{kritafile}"
    puts
    puts 'This will automatically find the GTK MRU data and display the list of files.'
    puts 'You can also pipe a file to it, as there may be multiple older GTK MRU files in the same directory.'
  end

  def run
    gtk
    krita
    generic

    report
  end

  def gtkfile open = true
    mrufile = datapath.join 'recently-used.xbel'

    if $stdin.tty? then
      if mrufile.exist? then
        if open then
          mrufile.open
        else
          mrufile
        end
      else # no file
        if open then
          puts "\e[31mno GTK MRU file found at: #{mrufile}\e[0m" unless @noheader
          # stub it out so the loop will skip it
          infile = StringIO.new
        else
          mrufile
        end
      end
    else # no tty means something is being piped in
      if open then
        infile = $stdin
      else
          mrufile
      end
    end
  end

  def gtk
    lines = gtkfile.readlines

    @gtk = 0
    lines.each do |line|
      m = line.match(/file:\/\/(.*?)"/)
      if m then
        if @gtk == 0 then
          puts "\e[34m# GTK MRU:\e[0m" unless @noheader
        end

        @gtk += 1
        puts unex m.captures.first
      end
    end
  end

  def genericpath
    datapath.join 'RecentDocuments'
  end

  def generic
    rd = genericpath

    @generic = 0
    rd.each_child do |f|
      pf = Pathname.new f
      next unless pf.file?
      pf.readlines.each do |line|
        m = line.match /^URL.*?=(.*)/
        if m then
          if @generic == 0 then
            puts "\e[33m# Generic MRU:\e[0m" unless @noheader
          end

          @generic += 1
          puts unex m.captures.first
        end
      end
    end
  end

  def kritafile
    configpath.join 'kritarc'
  end

  def krita
    @krita = 0
    kritafile.open.readlines.each do |line|
      m = line.match /^Name\d*=(.*)/
      if m then
        if @krita == 0 then
          puts "\e[35m# Krita:\e[0m" unless @noheader
        end

        @krita += 1
        puts unex m.captures.first
      end
    end
  end

  def report
    puts "\n\e[36m# #{@generic + @gtk} MRU files found in total\e[0m" unless @noheader
  end

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

