class AddRegularExpressionReplaceToPermission < ActiveRecord::Migration
  def change
    add_column :permissions, :regularExpressionReplace, :string
    add_column :permissions, :regularExpressionMatch, :string
  end
end
