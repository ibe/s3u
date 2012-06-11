class AddTrialToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :trial_id, :integer
    add_index :patients, :trial_id
  end
end
