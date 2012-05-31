require 'pathname'

# Controller for the Did utility.
class Did
  autoload :Sheet, "did/sheet"
  autoload :TagPool, "did/tag_pool"

  attr_reader :home

  def initialize home = nil
    @home = Did.resolve_home(home)
  end

  def command arguments
    case classify arguments
    when :log
      log arguments
    when :report
      report
    end
  end
  
  def log tags
    now = Time.now

    sheet = Did::Sheet.new(self, now)
    sheet.write(now, tags)

    tag_pool = Did::TagPool.new(self)
    tag_pool.add_tags(tags)
  end

  def report
    now = Time.now

    sheet = Did::Sheet.new(self, now)
    sheet.report
  end

  def autocomplete tag_fragment
    tag_pool = Did::TagPool.new(self)
    suggestions = tag_pool.autocomplete(tag_fragment)

    STDOUT << suggestions.join("\n")
  end

  private

  def classify arguments
    if arguments.include?("--report")
      :report
    else
      :log
    end
  end

  def self.resolve_home home
    Pathname.new(home || ENV['DID_HOME'] || Dir.pwd) + ".did"
  end
end
