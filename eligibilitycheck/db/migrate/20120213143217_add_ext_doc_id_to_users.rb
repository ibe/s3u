class AddExtDocIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :extDocId, :string
  end
end
