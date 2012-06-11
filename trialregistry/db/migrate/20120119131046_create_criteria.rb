class CreateCriteria < ActiveRecord::Migration
  def change
    create_table :criteria do |t|
      t.string :value
      t.string :criterion_type
      t.string :operator
      t.references :trial
      t.references :datum

      t.timestamps
    end
    add_index :criteria, :trial_id
    add_index :criteria, :datum_id
  end
end
