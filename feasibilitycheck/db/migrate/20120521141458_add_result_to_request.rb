class AddResultToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :result, :integer
  end
end
