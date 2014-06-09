require "spec_helper"

describe Person do
  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :description }
  it { should belong_to :user }
end
