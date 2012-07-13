class CreateConsents < ActiveRecord::Migration
  def change
    create_table :consents do |t|
      t.references :patient
      t.references :trial
      t.string :prenamePhysician
      t.string :surnamePhysician
      t.string :mailPhysician

      t.timestamps
    end
    add_index :consents, :patient_id
    add_index :consents, :trial_id
  end
end
