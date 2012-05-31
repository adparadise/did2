require 'pathname'

# A class to manage lists of all tags in this repository.
class Did::TagPool
  def initialize(did)
    @did = did
  end

  def add_tags(new_tags)
    write_tags (tags + new_tags).sort.uniq
  end

  def autocomplete(tag_fragment)
    regexp = Regexp.new "^#{tag_fragment}"
    tags.grep regexp
  end

  private

  def filepath
    @did.home + "tags"
  end

  def tags
    return [] if !filepath.exist?
    filepath.readlines.map {|line| line.strip}
  end

  def write_tags(tags)
    temp_filepath = Pathname.new(filepath.to_s + "_temp")
    File.open(temp_filepath, "w") do |file|
      file.write(tags.join("\n") + "\n")
    end
    File.rename(temp_filepath, filepath)
  end
end
