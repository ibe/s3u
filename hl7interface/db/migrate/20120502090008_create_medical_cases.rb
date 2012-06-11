class CreateMedicalCases < ActiveRecord::Migration
  def change
    create_table :medical_cases do |t|
      t.string :extId
      t.string :prename
      t.string :surname
      t.date :dob
      t.string :sex

      t.timestamps
    end
  end
end
