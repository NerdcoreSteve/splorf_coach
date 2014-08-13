class Person < ActiveRecord::Base
  belongs_to :user
  validates :first_name, :middle_name, :last_name, :description, presence: true
end
