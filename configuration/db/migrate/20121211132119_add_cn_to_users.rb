class AddCnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cn, :string
    add_index :users, :cn, :unique => true
    remove_index :users, :email
  end
end
