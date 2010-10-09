#!/usr/bin/ruby

puts ARGV

command = ARGV.shift

ARGV.each do |arg|
  if arg =~ /$--\a/ then # if this arg starts with two dashes and is immediately followed by an alphanumeric then..
    options << arg


    p @branch -- source @source = 'origin'
    pull --no-ff @source @branch
