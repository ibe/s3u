class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :dataSource
      t.string :messageControlId
      t.string :segment
      t.integer :composite
      t.integer :subcomposite
      t.integer :subsubcomposite

      t.timestamps
    end
  end
end
