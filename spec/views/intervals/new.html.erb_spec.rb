require 'spec_helper'

describe "intervals/new" do
  before(:each) do
    assign(:interval, stub_model(Interval,
      :user => nil
    ).as_new_record)
  end

  it "renders new interval form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => intervals_path, :method => "post" do
      assert_select "input#interval_user", :name => "interval[user]"
    end
  end
end
