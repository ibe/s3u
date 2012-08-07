#!/usr/bin/perl

use strict;
use warnings;

use Log::Log4perl;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Net::LDAP;
use MIME::Lite::TT::HTML;

# this line is only necessary, if run as cgi-script via apache
print "Content-type: text/html\n\n";

# loading/processing major config file
my %S3U_CONF;
open(CONFIG, "s3u_lmu_recruiter.conf");
while (<CONFIG>) {
  chomp;
  s/#.*//;
  s/^\s+//;
  s/\s+$//;
  next unless length;
  my ($var, $value) = split(/\s*=\s*/, $_, 2);
  $S3U_CONF{$var} = $value;
}

# initialize logging environment
Log::Log4perl->init($S3U_CONF{LOG4PERL_CONF});
my $log = Log::Log4perl->get_logger();

# step 1: connect to studienmonitor DB to get structured inclusion/exclusion criteria
my $dbh_studienmonitor = DBI->connect($S3U_CONF{DB_DSN_STUDIENMONITOR}, $S3U_CONF{DB_USER_STUDIENMONITOR}, $S3U_CONF{DB_PASSWORD_STUDIENMONITOR});
$dbh_studienmonitor && $log->info("1/... success: studienmonitor connection") || die $log->error("1/... failure: studienmonitor connection " . DBI::errstr);

my $dbh_webrequest = DBI->connect($S3U_CONF{DB_DSN_WEBREQUEST}, $S3U_CONF{DB_USER_WEBREQUEST}, $S3U_CONF{DB_PASSWORD_WEBREQUEST});
$dbh_webrequest && $log->info("1/... success: webrequest connection") || die $log->error("1/... failure: webrequest connection " . DBI::errstr);

# get all trials
my $sth = $dbh_webrequest->prepare("SELECT id FROM requests WHERE approved = 1");
$sth->execute();
my @trials = ();
# save trial ids in array of hashes
while (my $r = $sth->fetchrow_hashref) {
  my %result = (
    'id' => $r->{'id'}
  );
  push @trials, \%result;
}
$sth->finish();
$dbh_webrequest->disconnect();
$dbh_webrequest && $log->info("1/... success: studienmonitor disconnected - got " .@trials. " trials") || die $log->error("1/... failure: studienmonitor disconnected " . DBI::errstr);

# get current timestamp
(my $sec, my $min, my $hour, my $mday, my $mon, my $year, my $wday, my $yday, my $isdst) = localtime(time);
my $timestamp = sprintf "%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;

# iterate over trials
foreach (@trials) {
  my $i = $_;
  my $dbh_webrequest = DBI->connect($S3U_CONF{DB_DSN_WEBREQUEST}, $S3U_CONF{DB_USER_WEBREQUEST}, $S3U_CONF{DB_PASSWORD_WEBREQUEST});
  $dbh_webrequest && $log->info("2/... success: studienmonitor connection") || die $log->error("2/... failure: studienmonitor connection " . DBI::errstr);

  my $dbh_studienmonitor = DBI->connect($S3U_CONF{DB_DSN_STUDIENMONITOR}, $S3U_CONF{DB_USER_STUDIENMONITOR}, $S3U_CONF{DB_PASSWORD_STUDIENMONITOR});
  $dbh_studienmonitor && $log->info("2/... success: studienmonitor connection") || die $log->error("2/... failure: studienmonitor connection " . DBI::errstr);

  # get structured criteria for current trial
  $sth = $dbh_webrequest->prepare(
    "SELECT * FROM criteria WHERE request_id = '".${$i}{'id'}."'");
  $sth->execute();
  # initiate/empty criteria array of hashes
  my @criteria = ();
  $#criteria = -1;
  # get criteria one-by-one
  while (my $r = $sth->fetchrow_hashref) {
    my $sth2 = $dbh_studienmonitor->prepare(
      "SELECT * FROM data WHERE id = '".$r->{datum_id}."'"
    );
    $sth2->execute();
    my $r2 = $sth2->fetchrow_hashref();
    my %result = (
    'segment' => $r2->{'segment'},
    'composite' => $r2->{'composite'},
    'subcomposite' => $r2->{'subcomposite'},
    'subsubcomposite' => $r2->{'subsubcomposite'},
    'operator' => $r->{'operator'},
    'value' => $r->{'value'},
    'criterion_type' => $r->{'criterion_type'},
    'trial_id' => $r->{'request_id'},
    );
    push @criteria, \%result;
  }
  $sth->finish();
  # ok, we're done with the studienmonitor DB
  $dbh_studienmonitor->disconnect();
  $dbh_studienmonitor && $log->info("1/... success: studienmonitor disconnected - processed trial criteria") || die $log->error("1/... failure: studienmonitor disconnected " . DBI::errstr);

  $dbh_webrequest->disconnect();
  $dbh_webrequest && $log->info("1/... success: studienmonitor disconnected - processed trial criteria") || die $log->error("1/... failure: studienmonitor disconnected " . DBI::errstr);
  
  # step 2: connect to the hl7interface DB
  my $dbh_hl7interface = DBI->connect($S3U_CONF{DB_DSN_HL7IF}, $S3U_CONF{DB_USER_HL7IF}, $S3U_CONF{DB_PASSWORD_HL7IF});
  $dbh_hl7interface && $log->info("3/... success: hl7interface connection") || die $log->error("3/... failure: hl7interface connection " . DBI::errstr);

  # initiate several hashes/arrays
  my $criteria_size = @criteria;
  my @messageControlId_hits = ();
  my %possible_hits = ();
  my @trueHits = ();
  
  # iterate over all criteria logged in @criteria array
  for (my $j = 0; $j < $criteria_size; $j++) {
    # if we have an inclusion criteria build this sql statement ("... WHERE ... AND ...")
    if ($criteria[$j]->{'criterion_type'} eq "inclusion") {
      $sth = $dbh_hl7interface->prepare("SELECT distinct(messageControlId) FROM messages WHERE segment = '".$criteria[$j]->{'segment'}."' AND composite=".$criteria[$j]->{'composite'}." AND subcomposite = ".$criteria[$j]->{'subcomposite'}." AND subsubcomposite = ".$criteria[$j]->{'subsubcomposite'}." AND value ".$criteria[$j]->{'operator'}." '".$criteria[$j]->{'value'}."'");
      $sth->execute();
      while (my $r = $sth->fetchrow_hashref) {
        push @messageControlId_hits, $r->{'messageControlId'};
      }
    }
    # if we have an exclusion criteria build this sql statement ("... WHERE NOT ... AND NOT ...")
    else {
      $sth = $dbh_hl7interface->prepare("SELECT distinct(messageControlId) FROM messages WHERE NOT segment = '".$criteria[$j]->{'segment'}."' AND NOT composite=".$criteria[$j]->{'composite'}." AND NOT subcomposite = ".$criteria[$j]->{'subcomposite'}." AND NOT subsubcomposite = ".$criteria[$j]->{'subsubcomposite'}." AND NOT value ".$criteria[$j]->{'operator'}." '".$criteria[$j]->{'value'}."'");
      $sth->execute();
      while (my $r = $sth->fetchrow_hashref) {
        push @messageControlId_hits, $r->{'messageControlId'};
      }
    }
  }
  $sth->finish();

  # we now have to check, whether we have logged a trial that matches all criteria
  # (and therefor is *really* a hit). 
  for (@messageControlId_hits) {
    $possible_hits{$_}++;
  }
  foreach my $keys (keys %possible_hits) {
    if ($possible_hits{$keys} eq $criteria_size) {
      push @trueHits, $keys;
      $log->info("3/... success: identified hit");
    }
  }
  
  # if we do not have any hits for this trial, stop processing of this trial and go to next trial
  my $trueHits_count = @trueHits;
  if ($trueHits_count eq 0) {
    next;
  }

  $sth = $dbh_hl7interface->prepare("SELECT DISTINCT(value) FROM messages WHERE segment = 'PID' AND composite = 3 AND subcomposite = 0 AND subsubcomposite = 0 AND messageControlID IN ( " . join(',', @trueHits) . " )");
  $sth->execute();
  my $cc = 0;
  while (my $r = $sth->fetchrow_hashref) {
    $cc++;
  }
  
  $dbh_webrequest = DBI->connect($S3U_CONF{DB_DSN_WEBREQUEST}, $S3U_CONF{DB_USER_WEBREQUEST}, $S3U_CONF{DB_PASSWORD_WEBREQUEST});
  $dbh_webrequest && $log->info("2/... success: studienmonitor connection") || die $log->error("2/... failure: studienmonitor connection " . DBI::errstr);
  my $statement = "UPDATE requests SET result = ".$cc.", updated_at = '".$timestamp."' WHERE id = ".${$i}{'id'};
  $sth = $dbh_webrequest->prepare($statement);
  $sth->execute();

  # horray, we're done, let's get a beer :)
  $dbh_hl7interface->disconnect();
  $dbh_webrequest->disconnect();
}

#
# check for news
#

$dbh_webrequest = DBI->connect($S3U_CONF{DB_DSN_WEBREQUEST}, $S3U_CONF{DB_USER_WEBREQUEST}, $S3U_CONF{DB_PASSWORD_WEBREQUEST});
$dbh_webrequest && $log->info("4/... success: webinterface connection") || die $log->error("3/... failure: webinterface connection " . DBI::errstr);
$sth = $dbh_webrequest->prepare(
  "SELECT * FROM requests WHERE NOT result IS NULL"
);
$sth->execute();
my $request_hits = 0;
while (my $r = $sth->fetchrow_hashref) {
  buildScientistMail($r->{'mailContact'},$r->{'result'},$r->{'created_at'},$r->{'id'},$r->{'prenameContact'},$r->{'surnameContact'},$r->{'updated_at'});
  $request_hits++;
}

if ($request_hits) {
  buildAdministratorMail();
}
$dbh_webrequest->disconnect();

#
# build mail content for treating physicians
# requires one argument: $_[0] = mail address
#
sub buildScientistMail {
  my $recipient = $_[0];

  my %params;
  $params{hits} = $_[1];
  $params{date} = $_[2];
  $params{id} = $_[3];
  $params{prename} = $_[4];
  $params{surname} = $_[5];
  $params{url} = $S3U_CONF{FEASIBILITY_CHECK_URL} . "/" . $_[3];
  $params{check_date} = $_[6];

  my %options;
  $options{INCLUDE_PATH} = $S3U_CONF{MAIL_TEMPLATE_PATH_PHYSICIAN}; 
  
  my %template;
  $template{text} = $S3U_CONF{MAIL_TEMPLATE_FILE_SCIENTIST};
  $template{html} = $S3U_CONF{MAIL_TEMPLATE_FILE_SCIENTIST};
  
  my $msg = MIME::Lite::TT::HTML->new(
    From => $S3U_CONF{MAIL_SENDER},
#    To => $recipient,
    To => $S3U_CONF{DEBUG_MAIL_RECIPIENT},
    Subject => '[S3U][Feasibility Result] Ergebnis Ihrer Protocol Feasibility Anfrage',
    Template => \%template,
    TmplOptions => \%options,
    TmplParams => \%params,
    Charset => 'utf-8',
    Encoding => 'quoted-printable'
  );
  $msg->send();
  #print $msg->as_string;
}

#
# build mail content for trial personnel
# requires one argument: $_[0] = mail address
#
sub buildAdministratorMail {
  #my $trialPersonnel = $_[0];
  
  my %params;
  $params{url} = $S3U_CONF{FEASIBILITY_CHECK_URL};

  my %options;
  $options{INCLUDE_PATH} = $S3U_CONF{MAIL_TEMPLATE_PATH_PHYSICIAN};
  
  my %template;
  $template{text} = $S3U_CONF{MAIL_TEMPLATE_FILE_ADMINISTRATOR};
  $template{html} = $S3U_CONF{MAIL_TEMPLATE_FILE_ADMINISTRATOR};
  
  my $msg = MIME::Lite::TT::HTML->new(
    From => $S3U_CONF{MAIL_SENDER},
#    To => $trialPersonnel,
    To => $S3U_CONF{DEBUG_MAIL_RECIPIENT},
    Subject => '[S3U][Feasibility Digest] Übersicht über Feasibility Ergebnisse',
    Template => \%template,
    TmplOptions => \%options,
    TmplParams => \%params,
    Charset => 'utf-8',
    Encoding => 'quoted-printable'
  );
  $msg->send();
}