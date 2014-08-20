require 'rails_helper'

RSpec.describe "Buckets", :type => :request do
  describe "GET /buckets" do
    it "works! (now write some real specs)" do
      get buckets_path
      expect(response.status).to be(200)
    end
  end
end
