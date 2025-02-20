#!/usr/bin/env ruby

require 'pathname'
require 'set'

class ColorExtractor
  def initialize args
    @args = args
    @colors = Set.new
  end

  def usage
    <<~USAGE
      color_extractor - collect hex colors from text

      options:

      \t--border\tadds a border around color blots (requires --html)

      output format:

      \t--ary\toutput as valid Ruby array (also good for most other programming languages)
      \t--css\toutput as CSS
      \t--csv\toutput as CSV
      \t--html\toutput as a full HTML document
      \t--nl\toutput separated by newlines
      \t--sp\toutput separated by spaces

      usage:

      \tcolor_extractor filename
      \tcat filename | color_extractor

      Output will be a set of color codes, de-duplicated, and sorted.
    USAGE
  end

  def run
    parse_opts

    if $stdin.tty?
      extract_file
    else
      extract $stdin
    end

    display
  end

  def extract_file
    if !@file then
      warn usage
      warn "\e[31mno file specified\e[0m"
      exit 1
    end

    extract @file.open
  end

  REGHEX = /(#\h{6})/
  def extract input
    input.each_line do |line|
      m = line.match REGHEX
      if m then
        colors << m.captures.first
      end
    end
  end

  def display
    puts self.send @format
  end

  def csv
    list ', '
  end

  def nl
    list ?\n
  end

  def sp
    list ' '
  end

  def ary
    sorted.inspect
  end

  def css
    output = <<-CSS
      body {
        color: white;
        background-color: #CCC;
        font-weight: bold;
        font-family: "Jost", sans-serif;
      }
      .container {
        display: flex;
        flex-wrap: wrap;
      }
      .blot {
        #{css_style}
        height: 10em;
        width: 10em;
        flex: auto;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .label {
        border-radius: 2em;
        padding: 1em;
        color: #AAA;
        background-color: #333;
      }
      .label:hover {
        color: white;
        background-color: #333;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;
      }
    CSS

    sorted.each.with_index do |color, i|
      output << <<-CSS
        .color#{i} {
          background-color: #{color.upcase};
        }
      CSS
    end
    output
  end

  def palette
    output = ""
    sorted.each.with_index do |color, i|
      output << <<-HTML
        <div class="blot color#{i}"><span class="label">#{color.upcase}</span></div>
      HTML
    end
    output
  end

  def html
    <<~HTML
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Cutive&family=Jost:ital,wght@0,100..900;1,100..900&family=Roboto+Serif:ital,opsz,wght@0,8..144,100..900;1,8..144,100..900&display=swap">
        <style>
          #{css}
        </style>
      </head>
      <body>
        <div class="container">
          #{palette}
        </div>
      <body>
    HTML
  end

  def css_style
    if @border then
    <<-CSS
        border: 1em solid #555;
        border-radius: 3em;
        margin: 1em;
    CSS
    end
  end

  def list sep
    sorted.join sep
  end

  def sorted
    colors.to_a.sort
  end

  def colors
    @colors
  end

  def parse_opts
    new_args = []
    @format = :csv
    @args.each do |arg|
      case arg
      when '--border'
        @border = true
      when '--html'
        @format = :html
      when '--csv'
        @format = :csv
      when '--nl'
        @format = :nl
      when '--ary'
        @format = :ary
      when '--sp'
        @format = :sp
      when '--css'
        @format = :css
      when /^--help$|^-h$|^-\?$|^--version$/
        puts usage
        exit 0
      when '--'
        break # stop processing arguments
      else
        # presumably a filename
        f = Pathname.new arg
        unless f.exist? then
          warn usage
          warn "\e[31mfile not found: #{f}\e[0m"
          exit 1
        end
        @file = f
      end
    end
    @args = new_args
  end

  def filename
    @args.first
  end
end

ce = ColorExtractor.new ARGV
ce.run
