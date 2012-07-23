class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :prenameContact
      t.string :surnameContact
      t.string :mailContact
      t.string :phoneContact
      t.text :description

      t.timestamps
    end
  end
end
