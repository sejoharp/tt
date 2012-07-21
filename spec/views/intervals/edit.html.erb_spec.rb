require 'spec_helper'

describe "intervals/edit" do
  before(:each) do
    @interval = assign(:interval, stub_model(Interval,
      :user => nil
    ))
  end

  it "renders the edit interval form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "form", :action => intervals_path(@interval), :method => "post" do
    #  assert_select "input#interval_user", :name => "interval[user]"
    #end
  end
end
