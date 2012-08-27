class AddReadStatusToMedicalCases < ActiveRecord::Migration
  def change
    add_column :medical_cases, :read_status, :integer
  end
end
