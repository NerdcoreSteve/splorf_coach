class AddUserIdToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :user_id, :integer
    change_column_null :buckets, :user_id, false
  end
end
