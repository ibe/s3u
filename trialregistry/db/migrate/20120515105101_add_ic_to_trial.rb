class AddIcToTrial < ActiveRecord::Migration
  def change
    change_table :trials do |t|
      t.has_attached_file :informed_consent
    end
  end
end
