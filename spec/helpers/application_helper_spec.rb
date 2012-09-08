require 'spec_helper'

describe ApplicationHelper do
  it '-3601 is 1h 0 mins 1 secs and negative' do
    result = helper.calcuate_hours_mins_secs -3601
    result[:negative].should eq true
    result[:hours].should eq 1
    result[:mins].should eq 0
    result[:secs].should eq 1
  end
  it '-3601 secs will be displayed as - 1h 0mins' do
    helper.format_duration({:hours => 1,:mins => 0,:secs => 1, :negative => true}).should eq '- 1h 0mins'
  end
  it '3601 secs will be displayed as 1h 0mins' do
    helper.format_duration({:hours => 1,:mins => 0,:secs => 1}).should eq '1h 0mins'
  end
  it 'nil duration will be displayed as nothing' do
    helper.format_safe_duration(nil, nil).should eq ''
  end
  it '0 duration will be displayed as it is enough' do
    helper.format_safe_duration('it is enough', 0).should eq 'it is enough'
  end
  it '3661 duration will be displayed as 1h 1mins 1secs' do
    helper.format_safe_duration('it is enough', 3661).should eq '1h 1mins'
  end
end