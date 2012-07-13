class AddSubjectIdToConsent < ActiveRecord::Migration
  def up
    add_column :consents, :subject_id, :integer
  end
  
  def down
    remove_column :consents, :subject_id
  end
end
