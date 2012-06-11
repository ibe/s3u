class AddRegularExpressionToPermission < ActiveRecord::Migration
  def change
    add_column :permissions, :regularExpression, :string
  end
end
