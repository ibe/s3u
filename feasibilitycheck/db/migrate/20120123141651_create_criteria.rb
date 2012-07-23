class CreateCriteria < ActiveRecord::Migration
  def change
    create_table :criteria do |t|
      t.references :request
      t.references :datum
      t.string :criterion_type
      t.string :operator
      t.string :value

      t.timestamps
    end
    add_index :criteria, :request_id
    add_index :criteria, :datum_id
  end
end
