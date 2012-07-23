class AddSubmissionStatusToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :submit, :integer
  end
end
