class RenamePersonDescriptionToNotes < ActiveRecord::Migration
  def change
    rename_column :people, :description, :notes
  end
end
