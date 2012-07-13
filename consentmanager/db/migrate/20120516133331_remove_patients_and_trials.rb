class RemovePatientsAndTrials < ActiveRecord::Migration
  def up
    create_table :patients do |t|
    end
    create_table :trials do |t|
    end
    drop_table :patients
    drop_table :trials
  end

  def down
  end
end
