# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

# seed data like this for development environment:
# rake db:drop db:create db:migrate db:seed
# seed data like this for test environment:
# RAILS_ENV=test rake db:drop db:create db:migrate db:seed
# seed data like this for production environment:
# RAILS_ENV=production rake db:drop db:create db:migrate db:seed

case Rails.env
when "development"
  Patient.create([
    { :id => 1, :extId => '31008006', :extDocId => 'M36083', :prename => 'Benjamin', :surname => 'Hertz', :dob => '1985-09-02', :sex => 'M', :extDocID => 'M36083', :trial_id => 1, :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :id => 2, :extId => '29654630', :extDocId => 'M36083', :prename => 'Lucas', :surname => 'Schmidt', :dob => '1904-04-13', :sex => 'M', :extDocID => 'M36083', :trial_id => 2, :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :id => 3, :extId => '30099942', :extDocId => 'M36083', :prename => 'Juliane', :surname => 'Krüger', :dob => '1967-04-09', :sex => 'F', :extDocID => 'M36083', :trial_id => 1, :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :id => 4, :extId => '27167923', :extDocId => 'M36083', :prename => 'Nicole', :surname => 'Frei', :dob => '1958-05-03', :sex => 'F', :extDocID => 'M36083', :trial_id => 1, :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' }
  ])

  MedicalCase.create([
    { :id => 1, :extCaseId => '51009476', :patient_id => 1, :funcOu => 'CGUN', :nurseOu => 'CHGG2', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :id => 2, :extCaseId => '51007453', :patient_id => 3, :funcOu => 'CGAL', :nurseOu => 'CHGG2', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :id => 3, :extCaseId => '51008345', :patient_id => 2, :funcOu => 'HNAL', :nurseOu => 'HNGI7', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :id => 4, :extCaseId => '51008534', :patient_id => 4, :funcOu => 'HNAL', :nurseOu => 'HNGI7', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' }
  ])

  Diagnosis.create([
    { :medical_case_id => 1, :icd10Code => 'C54.1', :icd10Text => 'Bösartige Neubildung: Endometrium', :icd10Version => 'I10-V2011', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :medical_case_id => 2, :icd10Code => 'C62.1', :icd10Text => 'Bösartige Neubildung: Deszendierter Hode', :icd10Version => 'I10-V2011', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :medical_case_id => 3, :icd10Code => 'C54.1', :icd10Text => 'Bösartige Neubildung: Endometrium', :icd10Version => 'I10-V2011', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
    { :medical_case_id => 4, :icd10Code => 'C54.1', :icd10Text => 'Bösartige Neubildung: Endometrium', :icd10Version => 'I10-V2011', :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00' },
  ])

  User.create([
    { :created_at => '2012-01-01 09:00:00', :updated_at => '2012-01-01 09:00:00', :cn => 'my_user_account', :extDocId => 'M36083' }
  ])

when "test"
  # something
when "production"
  # something
end
