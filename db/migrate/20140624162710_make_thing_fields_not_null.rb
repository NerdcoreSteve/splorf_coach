class MakeThingFieldsNotNull < ActiveRecord::Migration
  def change
    change_column_null :things, :name, false
    change_column_null :things, :description, false
    change_column_null :things, :status, false
  end
end
