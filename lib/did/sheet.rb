require 'fileutils'
require 'time'
require 'set'

# A log of events for a particular day.
class Did::Sheet
  def initialize(did, date)
    @did = did
    @date = date
  end

  def write(time, tags)
    time_string = time.strftime("%Y-%m-%d %H:%M:%S %z")
    write_to_file "#{time_string} #{tags.join(" ")}\n"
  end

  def report
    tags = summary.keys.sort
    max_length = (tags.map{|tag| tag.length}.max || 0) + 1
    tags.each do |tag|
      duration = summary[tag]
      STDOUT << "#{tag.rjust(max_length)}: #{Did::Sheet.duration_to_string(duration)}\n"
    end
  end

  private

  def filepath
    date_string = @date.strftime("%Y-%m-%d")
    @did.home + date_string[0..6] + date_string
  end

  def write_to_file(contents)
    FileUtils.mkdir_p(filepath.dirname)
    File.open(filepath, "a") do |file|
      file.write(contents)
    end
  end

  def summary
    lines = File.readlines(filepath).map {|line| line.strip}
    summary = {}
    prior = nil
    lines.each do |line|
      fragments = line.split

      time = Time.parse(fragments[0..2].join(" "))
      tags = Set.new(fragments[3..-1])
      tags.add(tags.to_a.join(" "))

      if prior
        delta = time - prior
        tags.each do |tag|
          summary[tag] = (summary[tag] || 0) + delta
        end
      end
      prior = time
    end
    summary
  end

  def self.duration_to_string duration
    seconds = duration % 60
    minutes = ((duration - seconds) / 60) % 60
    hours = (duration - seconds - minutes * 60) / 360
    sprintf("%03d:%02d:%02d", hours, minutes, seconds)
  end
end
