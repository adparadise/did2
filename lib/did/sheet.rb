require 'fileutils'
require 'time'
require 'set'

# A log of events for a particular day.
class Did::Sheet
  include Enumerable

  def initialize(did, date)
    @did = did
    @date = date
  end

  def write(time, tags)
    time_string = time.strftime("%Y-%m-%d %H:%M:%S %z")
    write_to_file "#{time_string} #{tags.join(" ")}\n"
  end

  def report(arguments)
    tags = summary.keys.sort
    included = arguments.reject {|arg| arg =~ /^--/}
    is_filtered = included.length > 0
    STDOUT << "#{(" " * max_tags_length)}  #{date_description}\n"
    tags.each do |tag|
      if is_filtered
        next if included.detect {|arg| !tag.include? arg}
      end
      duration = summary[tag]
      STDOUT << "#{tag.rjust(max_tags_length)}: #{Did::Sheet.duration_to_s(duration)}\n"
    end
  end

  def date_description
    @date.strftime("%A, %B %-d, %Y")
  end

  def tree
    entropy = Did::Entropy.new
    entropy.build(self)
    puts entropy.priority
  end

  def list
    final_time = nil
    total_time = 0
    each do |time, tags, delta|
      STDOUT << "#{time} #{tags.join(" ").ljust(max_tags_length)} #{delta && Did::Sheet.duration_to_s(delta)}\n"
      total_time += delta if delta
      final_time = time
    end
    final_delta = Time.now - final_time
    STDOUT << "#{Time.now} #{"...".center(max_tags_length)} #{final_delta && Did::Sheet.duration_to_s(final_delta)}\n"
    STDOUT << "#{"total".rjust(max_tags_length + 26)} #{Did::Sheet.duration_to_s(total_time)}\n"
  end

  def self.duration_to_s duration
    seconds = duration % 60
    minutes = ((duration - seconds) / 60) % 60
    hours = (duration - seconds - minutes * 60) / (60 * 60)
    sprintf("%03d:%02d:%02d (% 6ds)", hours, minutes, seconds, duration)
  end

  def each
    prior = nil
    lines.each do |line|
      fragments = line.split

      time = Time.parse(fragments[0..2].join(" "))
      tags = fragments[3..-1]
      yield time, tags, (prior && time - prior) if !(tags[0] =~ /^\</)
      prior = time
    end
  end

  private

  def lines
    if !@lines
      @lines = []
      @lines = File.readlines(filepath).map {|line| line.strip} if filepath.exist?
      @lines = @lines.map {|line| line.length > 0 ? line : nil}.compact
    end
    @lines
  end

  def filepath
    date_string = @date.strftime("%Y-%m-%d")
    @did.home + date_string[0..6] + date_string
  end

  def max_tags_length
    @max_tags_length ||= (map {|time, tags| tags.join(" ").length}.max || 0) + 1
  end

  def write_to_file(contents)
    FileUtils.mkdir_p(filepath.dirname)
    File.open(filepath, "a") do |file|
      file.write(contents)
    end
  end

  def summary
    summary = {}
    each do |time, tags, delta|
      tag_set = Set.new(tags)
      tag_set.add(tags.join(" "))
      if delta
        tag_set.each do |tag|
          summary[tag] = (summary[tag] || 0) + delta
        end
      end
    end
    summary
  end

end
