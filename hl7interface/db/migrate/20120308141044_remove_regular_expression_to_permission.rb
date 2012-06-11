class RemoveRegularExpressionToPermission < ActiveRecord::Migration
  def up
    remove_column :permissions, :regularExpression
  end

  def down
    add_column :permissions, :regularExpression, :string
  end
end
