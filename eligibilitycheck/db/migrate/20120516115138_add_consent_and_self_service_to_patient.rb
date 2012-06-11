class AddConsentAndSelfServiceToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :consent_status, :integer
    add_column :patients, :self_service_status, :integer
  end
end
