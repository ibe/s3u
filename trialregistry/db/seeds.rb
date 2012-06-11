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

Datum.create([
  { :id => 1, :description => 'date of birth', :segment => 'PID', :composite => 7, :subcomposite => 0, :subsubcomposite => 0, :created_at => '2012-03-21 11:00:00', :updated_at => '2012-03-21 11:00:00' },
  { :id => 2, :description => 'sex', :segment => 'PID', :composite => 8, :subcomposite => 0, :subsubcomposite => 0, :created_at => '2012-03-21 11:00:00', :updated_at => '2012-03-21 11:00:00' },
  { :id => 3, :description => 'ICD-10 code', :segment => 'DG1', :composite => 3, :subcomposite => 0, :subsubcomposite => 0, :created_at => '2012-03-21 11:00:00', :updated_at => '2012-03-21 11:00:00' },
  { :id => 4, :description => 'nursing OU', :segment => 'PV1', :composite => 3, :subcomposite => 0, :subsubcomposite => 0, :created_at => '2012-03-21 11:00:00', :updated_at => '2012-03-21 11:00:00' },
  { :id => 5, :description => 'functional OU', :segment => 'PV1', :composite => 3, :subcomposite => 3, :subsubcomposite => 0, :created_at => '2012-03-21 11:00:00', :updated_at => '2012-03-21 11:00:00' }
])

case Rails.env
when "development"
  Trial.create([
    { :id => 1, :extId => 'TROUPER46', :description => 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.', :recruitingTarget => 20, :created_at => '2012-01-01 12:00:00', :updated_at => '2012-01-01 12:00:00', :prenameInvestigator => 'Max', :surnameInvestigator => 'Mustermann', :mailInvestigator => 'john.doe@foobar.com' },
    { :id => 2, :extId => 'LOLA12', :description => 'Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. ', :recruitingTarget => 48, :created_at => '2011-12-01 08:00:00', :updated_at => '2011-12-01 08:00:00', :prenameInvestigator => 'Miriam', :surnameInvestigator => 'Musterfrau', :mailInvestigator => 'john.doe@foobar.com' }
  ])
  
  Criterion.create([
    { :trial_id => 1, :datum_id => 2, :criterion_type => 'inclusion', :operator => '=', :value => 'M', :created_at => '2012-03-21 12:00:00', :updated_at => '2012-03-21 12:00:00' },
    { :trial_id => 1, :datum_id => 3, :criterion_type => 'inclusion', :operator => '=', :value => 'C62.1', :created_at => '2012-03-21 12:00:00', :updated_at => '2012-03-21 12:00:00' },
    { :trial_id => 2, :datum_id => 1, :criterion_type => 'inclusion', :operator => '<', :value => '1980-01-01', :created_at => '2012-03-21 12:00:00', :updated_at => '2012-03-21 12:00:00' }
  ])
when "test"
  # something
when "production"
  # something
end
