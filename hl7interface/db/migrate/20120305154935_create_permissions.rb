class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :dataSource
      t.string :segment
      t.integer :composite
      t.integer :subcomposite
      t.integer :subsubcomposite
      t.references :group

      t.timestamps
    end
    add_index :permissions, :group_id
  end
end
