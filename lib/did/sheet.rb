require 'fileutils'

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

  def filename
    date_string = @date.strftime("%Y-%m-%d")
    @did.home + "/#{date_string[0..6]}/#{date_string}"
  end

  def write_to_file(contents)
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, "a") do |file|
      file.write(contents)
    end
  end
end
