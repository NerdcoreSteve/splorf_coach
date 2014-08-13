class RenameThingsToBucketItems < ActiveRecord::Migration
  def self.up
    rename_table :things, :bucket_items
  end

 def self.down
    rename_table :bucket_items, :things
 end
end
