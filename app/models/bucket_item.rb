class BucketItem < ActiveRecord::Base
  belongs_to :user
  validates :name, :type, :bucket, :description, :status, presence: true
end
