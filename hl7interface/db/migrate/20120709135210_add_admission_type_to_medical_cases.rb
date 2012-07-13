class AddAdmissionTypeToMedicalCases < ActiveRecord::Migration
  def change
    add_column :medical_cases, :admissionType, :integer
  end
end
