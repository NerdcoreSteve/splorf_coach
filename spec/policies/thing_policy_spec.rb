require 'spec_helper'
require 'database_cleaner'
include Warden::Test::Helpers

describe ThingPolicy do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
  @user = FactoryGirl.create(:user)
  login_as @user, :scope => :user
  DatabaseCleaner.clean
end
