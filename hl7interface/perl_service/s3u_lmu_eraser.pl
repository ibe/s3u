#!/usr/bin/perl
use Log::Log4perl;
use DBI;
use DBD::mysql;

# loading/processing major config file
open(CONFIG, "s3u_lmu_services.conf");
while (<CONFIG>) {
  chomp;
  s/#.*//;
  s/^\s+//;
  s/\s+$//;
  next unless length;
  my ($var, $value) = split(/\s*=\s*/, $_, 2);
  $S3U_CONF{$var} = $value;
}

if ($S3U_CONF{ERASER_MODE} eq "DEBUG") {
  # this line is only necessary, if run as cgi-script via apache
  print "Content-type: text/html\n\n";  
}

# setting up log4perl
Log::Log4perl->init($S3U_CONF{LOG4PERL_ERASER_CONF});
my $log = Log::Log4perl->get_logger();

# calculating now minus 48 hours (or whatever timespan is defined within ERASER_TIMESPAN)
(my $sec, my $min, my $hour, my $mday, my $mon, my $year, my $wday, my $yday, my $isdst) = localtime(time - $S3U_CONF{ERASER_TIMESPAN});
my $now_minus_48_hours = sprintf "%4d%02d%02d%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;
my $now_minus_48_hours_f = sprintf "%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;

# connecting to DB
my $dbh = DBI->connect($S3U_CONF{KUM_DB_DSN},$S3U_CONF{KUM_DB_USER},$S3U_CONF{KUM_DB_PASSWORD}) or die $log->error(DBI::errstr);
my $sth;

# if we're in debug mode simply delete all
if ($S3U_CONF{ERASER_MODE} eq "DEBUG") {
  $sth = $dbh->do("DELETE FROM messages") or die $log->error($dbh->errstr);
  $sth = $dbh->do("DELETE FROM patients") or die $log->error($dbh->errstr);
  $sth = $dbh->do("DELETE FROM medical_cases") or die $log->error($dbh->errstr);
  $sth = $dbh->do("DELETE FROM diagnoses") or die $log->error($dbh->errstr);
  $log->info("running in debug mode therefor deleted all");
}
# else delete only those patients/cases/diagnoses that have been discharged for at least 48 hours
# (or whatever timespan is defined within ERASER_TIMESPAN)
else {
  $sth = $dbh->do(
    # first: delete all hl7 messages (and all datasets that have the same messageControlId)
    #        in which the value column is less than the defined ERASER_TIMESPAN
    "DELETE FROM messages WHERE messageControlId IN (
      SELECT messageControlId FROM (
        SELECT DISTINCT( m1.messageControlId ) FROM messages m1, messages m2 WHERE
        m2.segment = 'PV1' AND
        m2.composite = 45 AND
        m2.subcomposite = 0 AND
        m2.subsubcomposite = 0 AND
        m2.value < '".$now_minus_48_hours."' AND
        m1.messageControlId = m2.messageControlId
      ) AS tmptable
    )"
  ) or die $log->error($dbh->errstr);
  
  # identify patients who have been discharged for at least ERASER_TIMESPAN
  $sth = $dbh->prepare("SELECT id, patient_id FROM medical_cases WHERE dischargeDateTime < ?");
  $log->debug($now_minus_48_hours_f);
  $sth->execute($now_minus_48_hours_f) or die $log->error($dbh->errstr);
  my $rows = $sth->rows;
  my @patient_ids = ();
  my @medical_case_ids = ();
  while (my $r = $sth->fetchrow_hashref()) {
    $log->debug("deleting case id " . $r->{'id'});
    push @patient_ids, $r->{'patient_id'};
    push @medical_case_ids, $r->{'id'};
  }
  
  # delete all medical cases that have been discharged for at least ERASER_TIMESPAN
  $dbh->do("DELETE FROM medical_cases WHERE dischargeDateTime < ?", undef, $now_minus_48_hours_f) or die $log->error($dbh->errstr);
  
  # delete all corresponding diagnoses
  foreach (@medical_case_ids) {
    $dbh->do("DELETE FROM diagnoses WHERE medical_case_id = ?", undef, $_) or die $log->error($dbh->errstr);
    $log->debug("deleted diagnoses which are related to medical case id " . $_);
  }
  
  # delete all patients that have been discharged for at least ERASER_TIMESPAN and that do not
  # have another (not yet discharged) medical case
  foreach (@patient_ids) {
    $sth = $dbh->prepare("SELECT * FROM medical_cases WHERE patient_id = ?");
    $sth->execute($_) or die $log->error($dbh->errstr);
    $rows = $sth->rows;
    if ($rows == 0) {
      $dbh->do("DELETE FROM patients WHERE id = ?", undef, $_) or die $log->error($dbh->errstr);
      $log->debug("deleted patient id " . $_);
    }
  }
}

# haben wir patienten, fuer die keine faelle existieren? falls ja, loeschen
#$m4_sth = $m4_dbh->do("DELETE FROM sniffer_patient WHERE id NOT IN ( select patient_id from sniffer_case )") or die $log->error($m4_dbh->errstr);

# haben wir faelle, fuer die keine patienten existieren? falls ja, loeschen
# (sollte eigentlich typischerweise nichts finden, war nur waehrend der erstellung
#  des db-schemas interessant, als in sniffer_case.patient_id noch die i.s.h.med PatID
#  stand statt die korrespondierende sniffer_patient.id)
#$m4_sth = $m4_dbh->do("DELETE FROM sniffer_case WHERE patient_id NOT IN ( select id from sniffer_patient )") or die $log->error($m4_dbh->errstr);

# done. disconnecting.
$sth->finish();
$dbh->disconnect();
$log->info("finished successfully");

if ($S3U_CONF{ERASER_MODE} eq "DEBUG") {
  # this line is only necessary, if run as cgi-script via apache
  print "finished successfully";
}