require 'spec_helper'

describe User do
  it { should have_many :people }
  it { should have_many :things }
end
