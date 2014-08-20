require 'rails_helper'

RSpec.describe "buckets/index", :type => :view do
  before(:each) do
    assign(:buckets, [
      Bucket.create!(
        :name => "Name"
      ),
      Bucket.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of buckets" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
