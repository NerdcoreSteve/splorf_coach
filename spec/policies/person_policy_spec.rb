require 'spec_helper'
require 'pundit/rspec'

describe PersonPolicy do
  subject { PersonPolicy }

  let(:user) { FactoryGirl.create(:user) }
  let(:person) { FactoryGirl.create(:person, user: user) }

  #TODO index??
  #this would be a scope test I think, which is currently being done in the controller spec

  permissions :show?, :update?, :edit?, :destroy? do
    it 'should allow a user to see people in their own account' do
      expect(subject).to permit(user, person)
    end

    it 'should not allow a user to see people from other accounts' do
      expect(subject).to_not permit(user, FactoryGirl.create(:person))
    end
  end

  permissions :create?, :new? do
    it 'should allow a user to create a new person' do
      expect(subject).to permit(FactoryGirl.create(:person, user: user))
    end
  end
end
