class AddReadStatusToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :read_status, :integer
  end
end
