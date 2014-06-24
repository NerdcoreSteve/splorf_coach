class UserIdsAreNotNull < ActiveRecord::Migration
  def change
    change_column_null :people, :user_id, false
    change_column_null :things, :user_id, false
  end
end
