class RenameBucketItemDescriptionToNotes < ActiveRecord::Migration
  def change
    rename_column :bucket_items, :description, :notes
  end
end
