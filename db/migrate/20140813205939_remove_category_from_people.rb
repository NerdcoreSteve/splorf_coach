class RemoveCategoryFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :category, :string
  end
end
