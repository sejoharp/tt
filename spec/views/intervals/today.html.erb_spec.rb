require "spec_helper"

describe "intervals/today" do
  it "displays start button" do
    assign(:intervals, [
    	stub_model(Interval, :start => DateTime.now,:user => User.new(:name=>'testuser',:password=>'pw')),
    	stub_model(Interval, :start => DateTime.now,:user => User.new(:name=>'testuser',:password=>'pw'))
    	])
    assign(:is_working, false)

    render

    rendered.should =~ /start working/
    rendered.should_not =~ /stop working/
  end
	it "displays stop button" do
    assign(:intervals, [
    	stub_model(Interval, :start => DateTime.now,:user => User.new(:name=>'testuser',:password=>'pw')),
    	stub_model(Interval, :start => DateTime.now,:user => User.new(:name=>'testuser',:password=>'pw'))
    	])
    assign(:is_working, true)

    render

    rendered.should =~ /stop working/
    rendered.should_not =~ /start working/
  end
	it "displays a message that no intervals are available." do
    assign(:intervals, [])
    assign(:is_working, true)

    render

    rendered.should =~ /no intervals available/
    rendered.should =~ /todays intervals/
  end
end