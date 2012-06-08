require 'pathname'
require 'date'

# Controller for the Did utility.
class Did
  autoload :Sheet, "did/sheet"
  autoload :TagPool, "did/tag_pool"
  autoload :Entropy, "did/entropy"

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
      report arguments
    when :list
      list arguments
    when :tree
      tree
    end
  end
  
  def log tags
    now = Time.now

    sheet = Did::Sheet.new(self, now)
    sheet.write(now, tags)

    tag_pool = Did::TagPool.new(self)
    tag_pool.add_tags(tags)
  end

  def report(arguments)
    argument_params = Did::resolve_dates(arguments, Time.now)
    now = argument_params[:on]

    sheet = Did::Sheet.new(self, now)
    sheet.report(argument_params[:arguments])
  end

  def list(arguments)
    now = Time.now
    
    sheet = Did::Sheet.new(self, now)
    sheet.list
  end

  def tree
    now = Time.now
    sheet = Did::Sheet.new(self, now)
    sheet.tree
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
    elsif arguments.include?("--tree")
      :tree
    else
      :log
    end
  end

  def self.resolve_home home
    Pathname.new(home || ENV['DID_HOME'] || '~').expand_path + ".did"
  end

  def self.resolve_dates arguments, today
    result = {
      :arguments => [],
      :on => today
    }
    index = 0
    while index < 100
      break if index >= arguments.length
      if arguments[index] == "--on" && arguments[index + 1]
        date_params = Did::resolve_date(arguments, today, index + 1)
        result[:on] = date_params[:date]
        index += 1 + date_params[:offset]
      else 
        result[:arguments].push(arguments[index])
      end
      index += 1
    end
    result
  end

  def self.resolve_date arguments, today, index
    date_params = {
      :date => today,
      :offset => 0
    }
    if arguments[index] =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
      date_params[:date] = Date.strptime(arguments[index], "%Y-%m-%d")
      date_params[:offset] = 0
    end
    date_params
  end
end
