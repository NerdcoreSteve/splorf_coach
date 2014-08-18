class MakeBucketItemTypeAndBucketNotNull < ActiveRecord::Migration
  def change
    change_column_null :bucket_items, :bucket_item_type, false, "Thing"
    change_column_null :bucket_items, :bucket, false, "New Stuff"
  end
end
