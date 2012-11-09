class AddActivationToTrials < ActiveRecord::Migration
  def change
    add_column :trials, :activated, :boolean, :default => nil
  end
end
