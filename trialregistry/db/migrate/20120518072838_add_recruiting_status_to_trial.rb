class AddRecruitingStatusToTrial < ActiveRecord::Migration
  def change
    add_column :trials, :recruiting_status, :integer
  end
end
