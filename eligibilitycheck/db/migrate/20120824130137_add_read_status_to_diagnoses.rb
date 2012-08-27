class AddReadStatusToDiagnoses < ActiveRecord::Migration
  def change
    add_column :diagnoses, :read_status, :integer
  end
end
