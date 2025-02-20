#!/usr/bin/env ruby

require 'pathname'
require 'set'

class ColorExtractor
  def initialize args
    @args = args
    @colors = Set.new
  end

  def usage
    puts 'color_extractor - collect hex colors from text'
    puts
    puts "\tcolor_extractor filename"
    puts "\tcat filename | color_extractor"
    puts
    puts 'Output will be a set of color codes, de-duplicated, and sorted.'
  end

  def run
    if $stdin.tty?
      extract_file
    else
      extract $stdin
    end

    display
  end

  def extract_file
    if @args[0].empty? then
      usage
      exit 1
    end

    extract Pathname.new(@args[0]).open
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
    puts html
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
        height: 10em;
        width: 10em;
        border: 1em solid #555;
        border-radius: 3em;
        margin: 1em;
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
    <<-HTML
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

  def list sep
    sorted.join sep
  end

  def sorted
    colors.to_a.sort
  end

  def colors
    @colors
  end
end

ce = ColorExtractor.new ARGV
ce.run
