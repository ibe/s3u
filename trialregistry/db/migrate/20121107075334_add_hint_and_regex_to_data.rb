class AddHintAndRegexToData < ActiveRecord::Migration
  def change
    add_column :data, :hint, :text
    add_column :data, :regex, :string
  end
end
