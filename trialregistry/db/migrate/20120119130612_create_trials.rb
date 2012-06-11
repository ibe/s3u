class CreateTrials < ActiveRecord::Migration
  def change
    create_table :trials do |t|
      t.string :extId
      t.string :description
      t.integer :recruitingTarget

      t.timestamps
    end
  end
end
