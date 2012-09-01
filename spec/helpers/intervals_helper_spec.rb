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
  it '-3601 is 1h 0 mins 1 secs and negative' do
    result = helper.calcuate_hours_mins_secs -3601
    result[:negative].should eq true
    result[:hours].should eq 1
    result[:mins].should eq 0
    result[:secs].should eq 1
  end
  it '-3601 secs will be displayed as - 1h 0mins 1secs' do
    helper.format_duration({:hours => 1,:mins => 0,:secs => 1, :negative => true}).should eq '- 1h 0mins 1secs'
  end
  it '3601 secs will be displayed as 1h 0mins 1secs' do
    helper.format_duration({:hours => 1,:mins => 0,:secs => 1}).should eq '1h 0mins 1secs'
  end
  it 'nil duration will be displayed as nothing' do
    helper.format_safe_duration(nil, nil).should eq ''
  end
  it '0 duration will be displayed as it is enough' do
    helper.format_safe_duration('it is enough', 0).should eq 'it is enough'
  end
  it '3661 duration will be displayed as 1h 1mins 1secs' do
    helper.format_safe_duration('it is enough', 3661).should eq '1h 1mins 1secs'
  end
end
