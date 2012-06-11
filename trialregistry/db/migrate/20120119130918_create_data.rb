class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.string :description
      t.string :segment
      t.integer :composite
      t.integer :subcomposite
      t.integer :subsubcomposite

      t.timestamps
    end
  end
end
