class AddAdmitDismissDateTimeToMedicalCases < ActiveRecord::Migration
  def change
    add_column :medical_cases, :admitDateTime, :datetime
    add_column :medical_cases, :dischargeDateTime, :datetime
  end
end
