class AddApproveToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :approved, :boolean
  end
end
