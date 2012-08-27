class AddDocToMedicalCasesAndDiagnoses < ActiveRecord::Migration
  def change
    add_column :diagnoses, :extDocId, :string
    add_column :medical_cases, :extDocId, :string
  end
end
