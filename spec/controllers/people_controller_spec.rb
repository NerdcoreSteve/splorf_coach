require 'spec_helper'
include Devise::TestHelpers

describe PeopleController do
  let(:user1) { FactoryGirl.create(:user) }
  let(:user1_person) { FactoryGirl.create(:person, user: user1) }

  let(:user2) { FactoryGirl.create(:user, email: "dumbguy@professionalsteve.com") }
  let(:user2_person) { FactoryGirl.create(:person, user: user2) }

  before{ sign_in user1 }

  describe "Get #index" do
    it "populates an array of all the people associated with the current user" do
      get :index
      assigns(:people).should eq([user1_person])
    end
  end
end
