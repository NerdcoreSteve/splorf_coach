class RemoveStatusFromBucketItems < ActiveRecord::Migration
  def change
    remove_column :bucket_items, :status, :string
  end
end
