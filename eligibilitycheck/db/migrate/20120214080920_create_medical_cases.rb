class CreateMedicalCases < ActiveRecord::Migration
  def change
    create_table :medical_cases do |t|
      t.string :extCaseId
      t.references :patient
      t.string :funcOu
      t.string :nurseOu

      t.timestamps
    end
    add_index :medical_cases, :patient_id
  end
end
