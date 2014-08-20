class RemoveBucketStringFromBucketItems < ActiveRecord::Migration
  def change
    remove_column :bucket_items, :bucket, :string
  end
end
