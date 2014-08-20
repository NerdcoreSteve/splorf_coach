require 'rails_helper'

RSpec.describe "buckets/edit", :type => :view do
  before(:each) do
    @bucket = assign(:bucket, Bucket.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit bucket form" do
    render

    assert_select "form[action=?][method=?]", bucket_path(@bucket), "post" do

      assert_select "input#bucket_name[name=?]", "bucket[name]"
    end
  end
end
