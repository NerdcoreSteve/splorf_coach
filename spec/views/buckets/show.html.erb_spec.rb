require 'rails_helper'

RSpec.describe "buckets/show", :type => :view do
  before(:each) do
    @bucket = assign(:bucket, Bucket.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
