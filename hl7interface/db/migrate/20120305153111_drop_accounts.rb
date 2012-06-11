class DropAccounts < ActiveRecord::Migration
  def up
    create_table :accounts do |t|
      t.string :distinguishedName
      t.timestamps
    end
    drop_table :accounts
  end

  def down
    create_table :accounts do |t|
      t.string :distinguishedName
      t.timestamps
    end
  end
end