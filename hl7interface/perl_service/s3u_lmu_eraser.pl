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

Log::Log4perl->init($S3U_CONF{LOG4PERL_ERASER_CONF});
my $log = Log::Log4perl->get_logger();

(my $sec, my $min, my $hour, my $mday, my $mon, my $year, my $wday, my $yday, my $isdst) = localtime(time - $S3U_CONF{ERASER_TIMESPAN});
my $now_minus_48_hours = sprintf "%4d%02d%02d%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;
my $now_minus_48_hours_f = "2012-05-12 00:00:00";

my $kum_dbh = DBI->connect($S3U_CONF{KUM_DB_DSN},$S3U_CONF{KUM_DB_USER},$S3U_CONF{KUM_DB_PASSWORD}) or die $log->error(DBI::errstr);

my $kum_sth;

if ($S3U_CONF{ERASER_MODE} eq "DEBUG") {
  $kum_sth = $kum_dbh->do("DELETE FROM messages") or die $log->error($kum_dbh->errstr);
  $kum_sth = $kum_dbh->do("DELETE FROM patients") or die $log->error($kum_dbh->errstr);
  $kum_sth = $kum_dbh->do("DELETE FROM medical_cases") or die $log->error($kum_dbh->errstr);
  $kum_sth = $kum_dbh->do("DELETE FROM diagnoses") or die $log->error($kum_dbh->errstr);
  $log->info("running in debug mode therefor deleted all");
}
else {
  # haben wir faelle, die schon seit mehr als 48 stunden entlassen sind? falls ja, loeschen
  $kum_sth = $kum_dbh->do(
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
  ) or die $log->error($kum_dbh->errstr);
  
  $kum_sth = $kum_dbh->prepare("SELECT id, patient_id FROM medical_cases WHERE dischargeDateTime < ?");
  $kum_sth->execute($now_minus_48_hours_f) or die $log->error($kum_dbh->errstr);
  my $kum_rows = $kum_sth->rows;
  my @patient_ids = ();
  my @medical_case_ids = ();
  foreach ($kum_sth->fetchrow_hashref()) {
    push @patient_ids, $_->{'patient_id'};
    push @medical_case_ids, $_->{'id'};
  }
  
  $kum_dbh->do("DELETE FROM medical_cases WHERE dischargeDateTime < ?", undef, $now_minus_48_hours_f) or die $log->error($kum_dbh->errstr);
  
  foreach (@medical_case_ids) {
    $kum_dbh->do("DELETE FROM diagnoses WHERE medical_case_id = ?", undef, $_) or die $log->error($kum_dbh->errstr);
  }
  
  foreach (@patient_ids) {
    $kum_sth = $kum_dbh->prepare("SELECT * FROM medical_cases WHERE patient_id = ?");
    $kum_sth->execute($_) or die $log->error($kum_dbh->errstr);
    $kum_rows = $kum_sth->rows;
    if ($kum_rows == 0) {
      $kum_dbh->do("DELETE FROM patients WHERE id = ?", undef, $_) or die $log->error($kum_dbh->errstr);
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

$kum_dbh->disconnect();
$log->info("finished successfully");

if ($S3U_CONF{ERASER_MODE} eq "DEBUG") {
  # this line is only necessary, if run as cgi-script via apache
  print "finished successfully";
}