class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :prename
      t.string :surname
      t.string :mail
      t.string :phone
      t.references :ward

      t.timestamps
    end
    add_index :contacts, :ward_id
  end
end
