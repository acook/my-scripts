#!/usr/bin/env ruby

# Extracted from the Paint gem
module HexToAnsi
  module_function

    # Creates 256-compatible color from a html-like color string
    def hex(string, background = false)
      string.tr! '#',''
      rgb(
       *(if string.size == 6
          # string.chars.each_cons(2).map{ |hex_color| hex_color.join.to_i(16) }
          [string[0,2].to_i(16), string[2,2].to_i(16), string[4,2].to_i(16)]
        else
          string.chars.map{ |hex_color_half| (hex_color_half*2).to_i(16) }
        end + [background]) # 1.8 workaround
      )
    end

    # Creates a 256-compatible color from rgb values
    def rgb(red, green, blue, background = false)
      if mode == 8 || mode == 16
        "#{background ? 4 : 3}#{rgb_like_value(red, green, blue, mode == 16)}"
      else
        "#{background ? 48 : 38}#{rgb_value(red, green, blue)}"
      end
    end

    def mode
      256
    end

    # Returns nearest supported 256-color an rgb value, without fore-/background information
    # Inspired by the rainbow gem
    def rgb_value(red, green, blue)
      gray_possible = true
      sep = 42.5

      while gray_possible
        if red < sep || green < sep || blue < sep
          gray = red < sep && green < sep && blue < sep
          gray_possible = false
        end
        sep += 42.5
      end

      if gray
        ";5;#{ 232 + ((red.to_f + green.to_f + blue.to_f)/33).round }"
      else # rgb
        ";5;#{ [16, *[red, green, blue].zip([36, 6, 1]).map{ |color, mod|
          (6 * (color.to_f / 256)).to_i * mod
        }].inject(:+) }"
      end
    end
end

if ARGV.empty? then
  warn "usage: #{File.basename __FILE__} #BEDEAD"
  exit 1
else
  puts HexToAnsi.hex ARGV.first.dup
end
