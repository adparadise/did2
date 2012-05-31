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
    when :which
      which
    when :log
      log arguments
    when :report
      report
    when :list
      list arguments
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

  def list(arguments)
    now = Time.now
    
    sheet = Did::Sheet.new(self, now)
    sheet.list
  end

  def which
    STDOUT << "did home: #{@home.to_s}\n"
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
    elsif arguments.include?("--list")
      :list
    elsif arguments.include?("--which")
      :which
    else
      :log
    end
  end

  def self.resolve_home home
    Pathname.new(home || ENV['DID_HOME'] || '~').expand_path + ".did"
  end
end
