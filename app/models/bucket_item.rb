class BucketItem < ActiveRecord::Base
  belongs_to :user
  validates :name, :bucket_item_type, :bucket, :notes, :status, presence: true
end
