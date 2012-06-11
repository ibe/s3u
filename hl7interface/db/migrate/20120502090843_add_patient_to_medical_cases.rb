class AddPatientToMedicalCases < ActiveRecord::Migration
  def change
    add_column :medical_cases, :patient_id, :integer
  end
end
