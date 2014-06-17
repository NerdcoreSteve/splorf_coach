require 'spec_helper'
require 'pundit/rspec'

describe ThingPolicy do
  subject { ThingPolicy }

  let(:user) { FactoryGirl.create(:user) }
  let(:thing) { FactoryGirl.create(:thing, user: user) }

  permissions :show? do
    it 'should allow a user to see things in their own account' do
      expect(subject).to permit(user, thing)
    end

    it 'should not allow a user to see things from other accounts' do
      expect(subject).to_not permit(user, FactoryGirl.create(:thing))
    end
  end
end
