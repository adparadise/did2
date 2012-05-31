require 'rubygems'

$: << File.dirname(__FILE__) + "../lib"
require 'did'

describe Did::Sheet do
  describe ".duration_to_s" do
    it "should present seconds correctly" do
      result = Did::Sheet.duration_to_s(59)
      result[0..8].should eql "000:00:59"
    end

    it "should present minutes correctly" do
      result = Did::Sheet.duration_to_s(120)
      result[0..8].should eql "000:02:00"
    end

    it "should present hours correctly" do
      result = Did::Sheet.duration_to_s(2 * 60 * 60)
      result[0..8].should eql "002:00:00"
    end

    it "should present hours, minutes and seconds correctly" do
      result = Did::Sheet.duration_to_s(2 * 60 * 60 + 120 + 59)
      result[0..8].should eql "002:02:59"
    end
  end
end
