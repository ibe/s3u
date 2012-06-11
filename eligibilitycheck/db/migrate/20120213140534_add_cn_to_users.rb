class AddCnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cn, :string
  end
end
