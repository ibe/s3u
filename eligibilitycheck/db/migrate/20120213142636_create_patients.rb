class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :extId
      t.string :prename
      t.string :surname
      t.date :dob
      t.string :sex
      t.string :extDocId

      t.timestamps
    end
  end
end
