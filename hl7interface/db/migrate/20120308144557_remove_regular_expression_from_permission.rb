class RemoveRegularExpressionFromPermission < ActiveRecord::Migration
  def up
    remove_column :permissions, :regularExpressionMatch
    remove_column :permissions, :regularExpressionReplace
  end

  def down
    add_column :permissions, :regularExpressionMatch, :string
    add_column :permissions, :regularExpressionReplace, :string
  end
end
