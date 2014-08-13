require 'spec_helper'
require 'pundit/rspec'

describe ThingPolicy do
  subject { ThingPolicy }

  let(:user) { FactoryGirl.create(:user) }
  let(:bucket_item) { FactoryGirl.create(:bucket_item, user: user) }

  #TODO index??
  #this would be a scope test I think, which is currently being done in the controller spec

  permissions :show?, :update?, :edit?, :destroy? do
    it 'should allow a user to see bucket_items in their own account' do
      expect(subject).to permit(user, bucket_item)
    end

    it 'should not allow a user to see bucket_items from other accounts' do
      expect(subject).to_not permit(user, FactoryGirl.create(:bucket_item))
    end
  end

  permissions :create?, :new? do
    it 'should allow a user to create a new bucket_item' do
      expect(subject).to permit(FactoryGirl.create(:bucket_item, user: user))
    end
  end
end
