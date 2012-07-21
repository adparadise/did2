require 'pathname'
require 'date'

# Controller for the Did utility.
class Did
  autoload :Sheet, "did/sheet"
  autoload :TagPool, "did/tag_pool"
  autoload :Entropy, "did/entropy"
  autoload :Git, "did/git"

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
    when :timesheets
      timesheets arguments
    when :sync
      sync
    end
  end
  
  def log tags
    now = DateTime.now

    sheet = Did::Sheet.new(self, now)
    sheet.write(now, tags)

    tag_pool = Did::TagPool.new(self)
    tag_pool.add_tags(tags)
  end

  def report(arguments)
    argument_params = Did::resolve_dates(arguments, DateTime.now)
    now = argument_params[:on]

    sheet = Did::Sheet.new(self, now)
    sheet.report(argument_params[:arguments])
  end

  def list(arguments)
    now = DateTime.now
    
    sheet = Did::Sheet.new(self, now)
    sheet.list
  end

  def tree
    now = DateTime.now
    sheet = Did::Sheet.new(self, now)
    sheet.tree
  end

  def which
    STDOUT << "did home: #{@home.to_s}\n"
  end

  def sync
    git = Did::Git.new(self)
    STDOUT << git.sync
  end

  def timesheets arguments
    argument_params = Did::resolve_dates(arguments, DateTime.now)
    week = argument_params[:week]
    argument_params[:arguments] <<  "--rounded"

    sheets = Did::Sheet.sheets_week_of(self, week)
    max_tags_length = sheets.map do |sheet|
      sheet.max_tags_length
    end.max
    argument_params[:arguments] << "--indent-amount"
    argument_params[:arguments] << max_tags_length.to_s
    sheets.each do |sheet|
      sheet.report(argument_params[:arguments])
      STDOUT << "\n"
    end
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
    elsif arguments.include?("--sync")
      :sync
    elsif arguments.include?("--timesheets")
      :timesheets
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
      :on => today,
      :week => today
    }
    index = 0
    while index < 100
      break if index >= arguments.length
      if arguments[index] == "--on" && arguments[index + 1]
        date_params = Did::resolve_date_on(arguments, today, index + 1)
        result[:on] = date_params[:date]
        index += 1 + date_params[:offset]
      elsif arguments[index] == "--back" && arguments[index + 1]
        result[:week] = today - 7 * arguments[index + 1].to_i
        index += 1
      else 
        result[:arguments].push(arguments[index])
      end
      index += 1
    end
    result
  end

  def self.resolve_date_on arguments, today, index
    date_params = {
      :date => today,
      :offset => 0
    }
    days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    if arguments[index] =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/
      date_params[:date] = Date.strptime(arguments[index], "%Y-%m-%d")
      date_params[:offset] = 0
    elsif days.detect {|day| arguments[index][0..2].downcase == day}
      wday = days.index(arguments[index][0..2].downcase)
      day_offset = ((today.wday - wday) % 7)
      day_offset = 7 if day_offset == 0

      date_params[:date] = today - day_offset
      date_params[:offset] = 0
    end
    date_params
  end
end
