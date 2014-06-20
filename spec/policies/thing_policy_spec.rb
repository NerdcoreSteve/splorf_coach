require 'spec_helper'
require 'pundit/rspec'

describe ThingPolicy do
  subject { ThingPolicy }

  let(:user) { FactoryGirl.create(:user) }
  let(:thing) { FactoryGirl.create(:thing, user: user) }

  #TODO index??
  #this would be a scope test I think, which is currently being done in the controller spec

  permissions :show?, :update?, :edit?, :destroy? do
    it 'should allow a user to see things in their own account' do
      expect(subject).to permit(user, thing)
    end

    it 'should not allow a user to see things from other accounts' do
      expect(subject).to_not permit(user, FactoryGirl.create(:thing))
    end
  end

  permissions :create?, :new? do
    it 'should allow a user to create a new thing' do
      expect(subject).to permit(FactoryGirl.create(:thing, user: user))
    end
  end
end
