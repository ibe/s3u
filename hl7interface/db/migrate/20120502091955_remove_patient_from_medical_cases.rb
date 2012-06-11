class RemovePatientFromMedicalCases < ActiveRecord::Migration
  def up
    remove_column :medical_cases, :prename
    remove_column :medical_cases, :surname
    remove_column :medical_cases, :dob
    remove_column :medical_cases, :sex
    add_column :medical_cases, :extDocId, :string
  end

  def down
    add_column :medical_cases, :prename, :string
    add_column :medical_cases, :surname, :string
    add_column :medical_cases, :dob, :date
    add_column :medical_cases, :sex, :string
    remove_column :medical_cases, :extDocId
  end
end
