class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :prename
      t.string :surname

      t.timestamps
    end
  end
end
