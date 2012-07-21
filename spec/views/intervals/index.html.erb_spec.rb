require 'spec_helper'

describe "intervals/index" do
  before(:each) do
    assign(:intervals, [
      stub_model(Interval,
        :user => nil
      ),
      stub_model(Interval,
        :user => nil
      )
    ])
  end

  it "renders a list of intervals" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
