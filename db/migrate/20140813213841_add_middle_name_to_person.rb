class AddMiddleNameToPerson < ActiveRecord::Migration
  def change
    add_column :people, :middle_name, :string, :after => :first_name
  end
end
