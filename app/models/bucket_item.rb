class BucketItem < ActiveRecord::Base
  belongs_to :user
  validates :name, :bucket_item_type, :bucket, :description, :status, presence: true
end
