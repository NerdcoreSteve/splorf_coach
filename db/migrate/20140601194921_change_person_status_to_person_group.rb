class ChangePersonStatusToPersonGroup < ActiveRecord::Migration
  def change
    rename_column :people, :status, :category
  end
end
