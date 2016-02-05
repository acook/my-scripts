#!/usr/bin/env ruby

class Item
  def initialize url
    @url = url
  end
  attr :url, :filename
  attr :num_retries, :last_error
end

class Curl
  require 'open3'
  require 'securerandom'

  CURL = "curl"
  DL_ARGS = "--fail --retry 50 -C - -L --globoff"
  FN_ARGS = "-sI \"%s\""
  DEFAULT_ARGS = DL_ARGS + " -O --remote-header-name"

  def initialize
    @dl_args = nil
    @status = nil
  end

  def fetch url
    @dl_args = DEFAULT_ARGS
    @status = nil

    puts " -- Using \"#{@dl_args}\""
    puts " -- downloading \"#{url}\""

    Open3.popen3 [CURL, @dl_args, url].join(?\s) do |stdin, stdout, stderr, thread|
      stdin.close
      @status = thread.value.exitstatus
      p thread

      case @status
      when 0
        msg = " -- Looks like the download completed successfully, give it try."
        quit = true
      when 22
        msg = " -- Server issue encountered, check URL. Aborting."
        quit = true
      when 23
        msg = " -- Issues with filename, might be downloading a path.\n"
        msg << " -- Generating new filename...\n"

        name = fetch_name url

        msg << " -- Saving as \"#{name}\"\n"
        msg << " -- Use \`file\` command to determine filetype if its not clear."
        @dl_args = DL_ARGS + " -o #{name}"

        quit = false
      else
        msg = " -- Network trouble (probably), retrying..."
        msg << ?\n
        msg << stderr.read
        sleep 1
        quit = false
      end

      @msg = msg
    end
  end

  def fetch_name url
    Open3.popen3 [CURL, FN_ARGS % url].join(?\s) do |stdin, stdout, stderr, thread|
      @status = thread.value.exitstatus

      header = stdout.read

      m1 = header.match(/filename=(.*)\w*$/)
      if m1 && m1.captures.first && !m1.captures.first.empty? then
        f1 = m1.captures.first
      end

      m2 = header.match(/Location:(.*)\w*$/)
      if m2 && m2.captures.first && !m2.captures.first.empty? then
        f2 = File.basename m2.captures.first
      end

      f3 = "outfile_#{SecureRandom.hex(6)}"

      [f1, f2, f3].find{|m| !!m}
    end
  end

  def success?
    @status == 0
  end
end

class Downloader
  attr :urls
  attr :current_item, :pending_items, :completed_items

  def initialize env
    @env = env
    @pending_items = @env.items.dup
    @completed_items = Array.new
  end

  def download
    curl = Curl.new
    until current_item.nil? && pending_items.empty? do
      current_item = pending_items.pop unless current_item

      puts curl.fetch current_item.url

      if curl.success? then
        completed_items << current_item
        current_item = nil
      end
    end
  end
end

class Commandline
  def initialize args
    @args = args
  end
  attr :args

  def parse
    [args, nil]
  end
end

class Main
  def initialize args
    @args = args
  end
  attr :items, :args, :flags, :urls

  def go
    @urls, @flags = Commandline.new(ARGV).parse
    @items = @urls.map do |url|
      Item.new url
    end
    dl = Downloader.new self
    dl.download
  end
end

Main.new(ARGV).go

