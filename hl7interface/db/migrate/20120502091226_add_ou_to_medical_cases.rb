class AddOuToMedicalCases < ActiveRecord::Migration
  def change
    add_column :medical_cases, :funcOu, :string
    add_column :medical_cases, :nurseOu, :string
  end
end
