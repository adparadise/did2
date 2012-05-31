#!/usr/bin/env ruby

class Did
  attr_reader :home
  autoload :Sheet, "did/sheet"

  def initialize(home)
    @home = home
  end

  def log(tags)
    now = Time.now
    sheet = Did::Sheet.new(self, now)
    sheet.write(now, tags)
  end
end
