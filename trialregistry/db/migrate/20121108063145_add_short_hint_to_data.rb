class AddShortHintToData < ActiveRecord::Migration
  def change
    add_column :data, :hint_short, :string
  end
end
