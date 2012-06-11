class DropAccountsData < ActiveRecord::Migration
  def up
    create_table :accounts_data do |t|
      t.integer :account_id
      t.integer :datum_id
    end
    create_table :data do |t|
      t.integer :account_id
      t.integer :datum_id
      t.string  :dataSource
      t.string  :messageControlId
      t.string  :segment
      t.integer :composite
      t.integer :subcomposite
      t.integer :subsubcomposite
      t.datetime:created_at
      t.datetime:updated_at
    end    
    drop_table :accounts_data
    drop_table :data
  end

  def down
    create_table :accounts_data do |t|
      t.integer :account_id
      t.integer :datum_id
    end
    create_table :data do |t|
      t.integer :account_id
      t.integer :datum_id
      t.string  :dataSource
      t.string  :messageControlId
      t.string  :segment
      t.integer :composite
      t.integer :subcomposite
      t.integer :subsubcomposite
      t.datetime:created_at
      t.datetime:updated_at
    end    
  end
end
