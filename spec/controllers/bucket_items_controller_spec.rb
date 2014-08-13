require 'spec_helper'
include Devise::TestHelpers

describe BucketItemsController do
  let(:user1) { FactoryGirl.create(:user) }
  let(:user1_bucket_item) { FactoryGirl.create(:bucket_item, user: user1) }

  let(:user2) { FactoryGirl.create(:user, email: "dumbguy@professionalsteve.com") }
  let(:user2_bucket_item) { FactoryGirl.create(:bucket_item, user: user2) }

  before{ sign_in user1 }

  describe "Get #index" do
    it "populates an array of all the bucket_items associated with the current user" do
      get :index
      assigns(:bucket_items).should eq([user1_bucket_item])
    end
  end
end
