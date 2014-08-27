class AddBucketIdToBucketItem < ActiveRecord::Migration
  def change
    add_column :bucket_item, :bucket_id, :integer
  end
end
