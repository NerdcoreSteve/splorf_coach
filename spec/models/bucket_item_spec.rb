require "spec_helper"

describe BucketItem do
  it { should validate_presence_of :name }
  it { should validate_presence_of :type }
  it { should validate_presence_of :bucket }
  it { should validate_presence_of :description }
  it { should validate_presence_of :status }
  it { should belong_to :user }
end
