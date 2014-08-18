class RenameTypeColumnToBucketItemType < ActiveRecord::Migration
  def change
    rename_column :bucket_items, :type, :bucket_item_type
  end
end
