class AddValueToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :value, :string
  end
end
