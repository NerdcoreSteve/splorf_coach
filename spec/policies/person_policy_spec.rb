require 'spec_helper'
require 'pundit/rspec'

describe PersonPolicy do
  subject { PersonPolicy }

  let(:user) { FactoryGirl.create(:user) }
  let(:person) { FactoryGirl.create(:person, user: user) }

  permissions :show? do
    it 'should allow a user to see people in their own account' do
      expect(subject).to permit(user, person)
    end

    it 'should not allow a user to see people from other accounts' do
      expect(subject).to_not permit(user, FactoryGirl.create(:person))
    end
  end
end
