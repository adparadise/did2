
# A class to manage lists of all tags in this repository.
class Did::TagPool
  def initialize(did)
    @did = did
  end

  def add_tags(new_tags)
    write_tags (tags + new_tags).sort.uniq
  end

  private

  def filename
    @did.home + "/tags"
  end

  def tags
    return [] if !File.exist?(filename)
    File.readlines(filename).map {|line| line.strip}
  end

  def write_tags(tags)
    temp_filename = filename + "_temp"
    File.open(temp_filename, "w") do |file|
      file.write(tags.join("\n") + "\n")
    end
    File.rename(temp_filename, filename)
  end
end
