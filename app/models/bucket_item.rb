class BucketItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :bucket
  validates :name, :bucket_item_type, :notes, presence: true
end
