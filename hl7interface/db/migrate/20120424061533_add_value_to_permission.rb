class AddValueToPermission < ActiveRecord::Migration
  def change
    add_column :permissions, :value, :string
  end
end
