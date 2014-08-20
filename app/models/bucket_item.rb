class BucketItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :bucket
  validates :name, :bucket_item_type, :bucket, :notes, presence: true
end
