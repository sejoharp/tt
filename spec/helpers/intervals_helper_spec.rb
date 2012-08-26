require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the IntervalsHelper. For example:
#
# describe IntervalsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe IntervalsHelper do
  it 'datetime format is like 10.07.2012 10:11' do
  	helper.format_datetime(DateTime.new(2012,7,10,10,11)).should eq '10.07.2012 12:11'
  end
  it 'datetime format is like 12:11' do
  	datetime = DateTime.now.change({:hour=>10, :min => 11})
  	helper.format_time(datetime).should eq '10:11'
  end
  it 'datetimes from today look like 12:11' do
  	datetime = DateTime.now.change({:hour=>10, :min => 11})
  	helper.format_datetime_depending_on_date(datetime).should eq '10:11'
  end
  it 'datetimes from past look like 10.07.2012 12:11' do
  	datetime = DateTime.new(2012,7,10,10,11)
  	helper.format_datetime_depending_on_date(datetime).should eq '10.07.2012 12:11'
  end
end
