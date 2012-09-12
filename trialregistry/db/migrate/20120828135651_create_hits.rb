class CreateHits < ActiveRecord::Migration
  def change
    create_table :hits do |t|
      t.references :trial
      t.string :nurse_ou
      t.string :func_ou
      t.string :ext_doc_id

      t.timestamps
    end
    add_index :hits, :trial_id
  end
end
