class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :distinguishedName
      t.string :description

      t.timestamps
    end
  end
end
