class Thing < ActiveRecord::Base
  belongs_to :user
  validates :name, :description, :status, presence: true
end
