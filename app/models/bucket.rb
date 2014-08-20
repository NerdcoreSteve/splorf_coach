class Bucket < ActiveRecord::Base
  belongs_to :user
  has_many :bucket_items
  validates :name
end
