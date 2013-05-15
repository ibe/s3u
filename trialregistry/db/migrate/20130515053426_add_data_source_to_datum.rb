class AddDataSourceToDatum < ActiveRecord::Migration
  def change
    add_column :data, :data_source, :string
  end
end
