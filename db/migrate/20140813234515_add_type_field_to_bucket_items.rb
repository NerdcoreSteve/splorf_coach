class AddTypeFieldToBucketItems < ActiveRecord::Migration
  def change
    add_column :bucket_items, :type, :string
    add_column :bucket_items, :bucket, :string
  end
end
