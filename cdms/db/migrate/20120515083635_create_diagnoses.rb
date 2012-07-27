class CreateDiagnoses < ActiveRecord::Migration
  def change
    create_table :diagnoses do |t|
      t.string :icd10Code
      t.string :icd10Text
      t.string :icd10Version
      t.references :medical_case

      t.timestamps
    end
    add_index :diagnoses, :medical_case_id
  end
end
