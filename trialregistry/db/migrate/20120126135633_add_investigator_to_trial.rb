class AddInvestigatorToTrial < ActiveRecord::Migration
  def change
    change_table :trials do |t|
      t.string :prenameInvestigator
      t.string :surnameInvestigator
      t.string :mailInvestigator
    end
  end
end
