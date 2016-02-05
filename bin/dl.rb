#!/usr/bin/env ruby

class Item

  CODE_MSG = Hash.new(" -- Network trouble (probably), retrying.").merge(
    {
      0 => " -- Looks like the download completed successfully, give it try.",
      22 => " -- Server issue encountered, check URL. Aborting.",
      23 => " -- Issues with filename, might be downloading a path.",
    }
  )

  def initialize url
    @url = url
    @results = Hash.new
    @msgs = Array.new
    @filename = File.basename(url)
  end
  attr :url, :filename
  attr :results, :status_code, :msgs
  attr_accessor :curl_args

  def success?
    @status_code == 0
  end

  def status_code= code
    if code == 23 then
      @determine_filetype = true
    end

    @status_code = code
  end

end

class Curl
  require 'open3'
  require 'securerandom'

  CURL = "curl"
  DL_ARGS = "-# -C - -L --globoff"
  FN_ARGS = "-sI \"%s\""
  DEFAULT_ARGS = DL_ARGS + " -O --remote-header-name"

  def initialize item
    @item = item
    @item.curl_args = DEFAULT_ARGS
  end

  def fetch
    puts " -- Using \"#{@item.curl_args}\""
    puts " -- Downloading \"#{@item.url}\""

    Open3.popen3 [CURL, @item.curl_args, @item.url].join(?\s) do |stdin, stdout, stderr, thread|
      stdin.close
      @item.status_code = thread.value.exitstatus

      case @item.status_code
      when 0
        @item.msgs << " -- Success."
        @done = true
      when 22
        @item.msgs << " -- Server error."
        @done = true
      when 23
        name = self.class.new(@item).fetch_name
        @item.filename = name
        @item.curl_args = DL_ARGS + " -o #{name}"
        @item.msgs << " -- Saving as \"#{name}\"."
        @done = false
      else
        sleep 1
        @item.msgs << " -- Retrying..."
        @done = false
      end

      @item.results[@item.status_code] = stderr.read

      @done
    end
  end

  def fetch_name
    Open3.popen3 [CURL, FN_ARGS % @item.url].join(?\s) do |stdin, stdout, stderr, thread|
      @status = thread.value.exitstatus

      header = stdout.read

      m1 = header.match(/filename=(.*)$/)
      if m1 && m1.captures.first && !m1.captures.first.empty? then
        f1 = m1.captures.first.strip
      end

      m2 = header.match(/Location:(.*)$/)
      if m2 && m2.captures.first && !m2.captures.first.empty? then
        f2 = File.basename m2.captures.first.strip
      end

      f3 = "outfile_#{SecureRandom.hex(6)}"

      [f1, f2, f3].find{|m| !!m}
    end
  end

  def done?
    @done
  end
end

class Manager
  attr :current_item, :pending_items, :completed_items

  def initialize env
    @env = env
    @pending_items = @env.items.dup
    @completed_items = Array.new
  end

  def download
    current_item = pending_items.pop
    curl = Curl.new(current_item)

    until current_item.nil? do
      curl.fetch

      puts current_item.msgs.last
      if curl.done? then
        completed_items << current_item
        current_item = pending_items.pop
        curl = Curl.new(current_item)
      end
    end

    completed_items.each do |item|
      puts item.inspect
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
    dl = Manager.new self
    dl.download
  end
end

Main.new(ARGV).go

