require 'fileutils'

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
end
