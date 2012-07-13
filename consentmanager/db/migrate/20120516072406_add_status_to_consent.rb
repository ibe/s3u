class AddStatusToConsent < ActiveRecord::Migration
  def change
    add_column :consents, :status, :integer
  end
end
