class CreatePhysicians < ActiveRecord::Migration
  def change
    create_table :physicians do |t|
      t.references :trial
      t.string :extDocId
      t.integer :counter

      t.timestamps
    end
    add_index :physicians, :trial_id
  end
end
