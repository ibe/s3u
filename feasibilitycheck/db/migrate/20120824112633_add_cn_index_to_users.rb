class AddCnIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :cn,                :unique => true
    remove_index :users, :email
  end
end
