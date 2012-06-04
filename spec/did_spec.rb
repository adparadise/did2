require 'rubygems'

$: << File.dirname(__FILE__) + "../lib"
require 'did'

describe Did::Sheet do
  def today
    Date.new(2012,6,5)
  end
  
  describe ".resolve_date" do
    describe "when given a valid date" do
      it "should resolve the date" do
        date_params = Did::resolve_date(["2012-03-14"], today, 0)
        date_params[:date].should eql Date.new(2012, 3, 14)
      end
      
      it "should not advance the index more than the standard" do
        date_params = Did::resolve_date(["2012-03-14"], today, 0)
        date_params[:offset].should eql 0
      end
    end
  end

  describe ".resolve_dates" do
    describe "when not including a date" do
      it "should return the arguments unchanged" do
        argument_params = Did::resolve_dates(["test", "other"], today)
        argument_params[:arguments].should eql ["test", "other"]
      end
    end

    describe "when including a valid date" do
      it "should consume the date flag and argument" do
        argument_params = Did::resolve_dates(["--on", "2012-05-03"], today)
        argument_params[:arguments].should eql []
      end

      it "should set the on property" do
        argument_params = Did::resolve_dates(["--on", "2012-05-03"], today)
        argument_params[:on].should eql Date.new(2012, 5, 3)
      end
    end
  end
end
