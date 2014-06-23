require 'spec_helper'
include Devise::TestHelpers

describe ThingsController do
  let(:user1) { FactoryGirl.create(:user) }
  let(:user1_thing) { FactoryGirl.create(:thing, user: user1) }

  let(:user2) { FactoryGirl.create(:user, email: "dumbguy@professionalsteve.com") }
  let(:user2_thing) { FactoryGirl.create(:thing, user: user2) }

  before{ sign_in user1 }

  describe "Get #index" do
    it "populates an array of all the things associated with the current user" do
      get :index
      assigns(:things).should eq([user1_thing])
    end
  end
end
