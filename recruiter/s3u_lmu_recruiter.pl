#!/usr/bin/perl

use strict;
use warnings;

use Log::Log4perl;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Net::LDAP;
use MIME::Lite::TT::HTML;
use JSON;
use REST::Client;

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

my $sth;

# allow self-signed ssl certificates (hopefully not needed in production environment)
# http://search.cpan.org/~gaas/libwww-perl-6.04/lib/LWP.pm#ENVIRONMENT
BEGIN { $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0 }
my $client = REST::Client->new();
$client->GET($S3U_CONF{TRIALS_LIST_URL});
my $response = from_json($client->responseContent());
my @a = @$response;
my @trials = ();
foreach (@a) {
  my %h = %{$_};
  my %result = (
    'id' => $h{'id'}
  );
  # process only trials that have been activated
  if ($h{'activated'}) {
    push @trials, \%result;
  }
}

$client->GET($S3U_CONF{WARDS_LIST_URL});
$response = from_json($client->responseContent());
@a = @$response;
my @wards = ();
foreach (@a) {
  my %h = %{$_};
  my %result = (
    'id' => $h{'id'},
    'name' => $h{'name'}
  );
  push @wards, \%result;
  print "$h{'name'} \n";
}

$client->GET($S3U_CONF{WARDS_CONTACT_LIST_URL});
$response = from_json($client->responseContent());
@a = @$response;
my @contacts = ();
foreach (@a) {
  my %h = %{$_};
  my %result = (
    'id' => $h{'id'},
    'name' => $h{'surname'},
    'mail' => $h{'mail'},
    'phone' => $h{'phone'},
    'ward_id' => $h{'ward_id'}
  );
  push @contacts, \%result;
  print "$h{'ward_id'} \n";
}

# get current timestamp
(my $sec, my $min, my $hour, my $mday, my $mon, my $year, my $wday, my $yday, my $isdst) = localtime(time);
my $timestamp = sprintf "%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;

# iterate over trials
foreach (@trials) {
  my $i = $_;
  $dbh_studienmonitor = DBI->connect($S3U_CONF{DB_DSN_STUDIENMONITOR}, $S3U_CONF{DB_USER_STUDIENMONITOR}, $S3U_CONF{DB_PASSWORD_STUDIENMONITOR});
  $dbh_studienmonitor && $log->info("2/... success: studienmonitor connection") || die $log->error("2/... failure: studienmonitor connection " . DBI::errstr);

  # get structured criteria for current trial
  $sth = $dbh_studienmonitor->prepare(
    "SELECT c.*, d.segment, d.composite, d.subcomposite, d.subsubcomposite FROM criteria c, data d WHERE c.datum_id = d.id AND c.trial_id = '".${$i}{'id'}."'");
  $sth->execute();
  # initiate/empty criteria array of hashes
  my @criteria = ();
  $#criteria = -1;
  # get criteria one-by-one
  while (my $r = $sth->fetchrow_hashref) {
    my %result = (
    'segment' => $r->{'segment'},
    'composite' => $r->{'composite'},
    'subcomposite' => $r->{'subcomposite'},
    'subsubcomposite' => $r->{'subsubcomposite'},
    'operator' => $r->{'operator'},
    'value' => $r->{'value'},
    'criterion_type' => $r->{'criterion_type'},
    'trial_id' => $r->{'trial_id'},
    );
    push @criteria, \%result;
  }
  $sth->finish();
  # ok, we're done with the studienmonitor DB
  $dbh_studienmonitor->disconnect();
  $dbh_studienmonitor && $log->info("1/... success: studienmonitor disconnected - processed trial criteria") || die $log->error("1/... failure: studienmonitor disconnected " . DBI::errstr);
  
  # step 2: connect to the hl7interface DB
  my $dbh_hl7interface = DBI->connect($S3U_CONF{DB_DSN_HL7IF}, $S3U_CONF{DB_USER_HL7IF}, $S3U_CONF{DB_PASSWORD_HL7IF});
  $dbh_hl7interface && $log->info("3/... success: hl7interface connection") || die $log->error("3/... failure: hl7interface connection " . DBI::errstr);

  # step 3: connect to the aerzte_ui DB an insert all true hits into it
  my $dbh_aerzte_ui = DBI->connect($S3U_CONF{DB_DSN_WEBINTERFACE}, $S3U_CONF{DB_USER_WEBINTERFACE}, $S3U_CONF{DB_PASSWORD_WEBINTERFACE});
  $dbh_aerzte_ui && $log->info("4/... success: webinterface connection") || die $log->error("3/... failure: webinterface connection " . DBI::errstr);

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

  # create dataset for aerzte_ui DB - i.e. transpose datasets from hl7interface DB
  my %dataset = ();
  foreach (@trueHits) {
    $dataset{'trial_id'} = ${$i}{'id'};
    
    my $select = "SELECT DISTINCT(value) FROM messages WHERE messageControlId = '" . $_ . "'";
    
    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PID' AND composite = 3 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    my $r = $sth->fetchrow_hashref;
    $dataset{'extId'} = $r->{'value'};
    if ($dataset{'extId'}) {
      $dataset{'extId'} =~ s/^0*(.*)/$1/g;
    }

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PID' AND composite = 5 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'surname'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PID' AND composite = 5 AND subcomposite = 1 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'prename'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PID' AND composite = 7 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'dob'} = $r->{'value'};
    if ($dataset{'dob'}) {
      $dataset{'dob'} =~ s/(....)(..)(..)/$1-$2-$3/g;
    }

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PID' AND composite = 8 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'sex'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PV1' AND composite = 7 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'extDocId'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PV1' AND composite = 3 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'nurseOu'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PV1' AND composite = 3 AND subcomposite = 3 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'funcOu'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PV1' AND composite = 44 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'admitDateTime'} = $r->{'value'};
    if ($dataset{'admitDateTime'}) {
      $dataset{'admitDateTime'} =~ s/(....)(..)(..)(..)(..)(..)/$1-$2-$3 $4:$5:$6/g;
    }

    #$sth = $dbh_hl7interface->prepare($select . " AND segment = 'PV1' AND composite = 45 AND subcomposite = 0 AND subsubcomposite = 0");
    #$sth->execute();
    #$r = $sth->fetchrow_hashref;
    #$dataset{'dischargeDateTime'} = $r->{'value'};
    #$dataset{'dischargeDateTime'} =~ s/(....)(..)(..)(..)(..)(..).*/$1-$2-$3 $4:$5:$6/g;

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'PV1' AND composite = 19 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'extCaseId'} = $r->{'value'};
    if ($dataset{'extCaseId'}) {
      $dataset{'extCaseId'} =~ s/^0*(.*)/$1/g;
    }

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'DG1' AND composite = 3 AND subcomposite = 1 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'icd10Text'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'DG1' AND composite = 3 AND subcomposite = 2 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'icd10Version'} = $r->{'value'};

    $sth = $dbh_hl7interface->prepare($select . " AND segment = 'DG1' AND composite = 3 AND subcomposite = 0 AND subsubcomposite = 0");
    $sth->execute();
    $r = $sth->fetchrow_hashref;
    $dataset{'icd10Code'} = $r->{'value'};
  
    $sth->finish();
    $log->debug("build dataset: trial: " . $dataset{'trial_id'} . " extId: " . $dataset{'extId'} . " surname: " . $dataset{'surname'} . " prename: " . $dataset{'prename'} . " dob: " . $dataset{'dob'} . " sex: " . $dataset{'sex'} . " extDocId: " . $dataset{'extDocId'} . " nurseOu: " . $dataset{'nurseOu'} . " funcOu: " . $dataset{'funcOu'}  . " admitDateTime: " . $dataset{'admitDateTime'} . " extCaseId: " . $dataset{'extCaseId'} . " icd10Text: " . $dataset{'icd10Text'} . " icd10Code: " . $dataset{'icd10Code'} . " icd10Version: " . $dataset{'icd10Version'});
    
    # if we have at least the two OU's (nursing and functional) then we write the hit to the trialregistry
    if ($dataset{'nurseOu'} && $dataset{'funcOu'}) {
      $dbh_studienmonitor = DBI->connect($S3U_CONF{DB_DSN_STUDIENMONITOR}, $S3U_CONF{DB_USER_STUDIENMONITOR}, $S3U_CONF{DB_PASSWORD_STUDIENMONITOR});
      $dbh_studienmonitor && $log->info("2/... success: studienmonitor connection") || die $log->error("2/... failure: studienmonitor connection " . DBI::errstr);
      my $ext_doc_id = "";
       if ($dataset{'extDocId'} ne "") {
         $ext_doc_id = $dataset{'extDocId'};
      }
      $sth = $dbh_studienmonitor->prepare("INSERT INTO hits (trial_id, nurse_ou, func_ou, ext_doc_id, created_at) VALUES ('". $dataset{'trial_id'} ."', '".$dataset{'nurseOu'}."', '". $dataset{'funcOu'}. "', '". $ext_doc_id ."', '". $timestamp. "')");
      $sth->execute();
      $dbh_studienmonitor->disconnect();
    }

    # master requirement: we need a physician associated with the patient
    if ($dataset{'extDocId'}) {
      # check if we have an identical patient already in the patients table
      $sth = $dbh_aerzte_ui->prepare("SELECT id FROM patients WHERE extId = ".$dataset{'extId'}." AND extDocId = '".$dataset{'extDocId'}."' AND surname = '".$dataset{'surname'}."' AND prename = '".$dataset{'prename'}."' AND dob = '".$dataset{'dob'}."' AND sex = '".$dataset{'sex'}."' AND trial_id = ".$dataset{'trial_id'});
      $sth->execute();
      my $intId = 0;
      my $count = 0;
      while (my $r = $sth->fetchrow_hashref) {
        $count++;
        $intId = $r->{'id'};
      }
      # patient is not yet in the patients table
      if (! $count) {
        # insert the patients' part in the patients table
        $sth = $dbh_aerzte_ui->prepare("INSERT INTO patients (extId, extDocId, surname, prename, dob, sex, trial_id, created_at, updated_at) VALUES ('" .$dataset{'extId'}. "', '". $dataset{'extDocId'} ."', '". $dataset{'surname'} ."', '". $dataset{'prename'} ."', '". $dataset{'dob'} ."', '". $dataset{'sex'} ."', ". $dataset{'trial_id'} .", '". $timestamp ."', '". $timestamp ."')");
        $sth->execute();
        # get the autoincrement primary key of the patients table (we need this as foreign key at the medical_case table)
        $intId = $dbh_aerzte_ui->last_insert_id(undef,undef,undef,undef);
      }
  
      # check if we have an identical medical case already in the medical_cases table
      $sth = $dbh_aerzte_ui->prepare("SELECT id FROM medical_cases WHERE patient_id = ".$intId." AND extCaseId = ".$dataset{'extCaseId'}." AND nurseOu = '".$dataset{'nurseOu'}."' AND funcOu = '".$dataset{'funcOu'}."'");
      $sth->execute();
      my $intCaseId = 0;
      $count = 0;
      while (my $r = $sth->fetchrow_hashref) {
        $count++;
        $intCaseId = $r->{'id'};
      }
      # medical case is not yet in the medical_cases table
      if (! $count) {
        # insert the case part in the medical_cases table (only if there is a case at all)
        $sth = $dbh_aerzte_ui->prepare("INSERT INTO medical_cases (patient_id, extDocId, extCaseId, nurseOu, funcOu, created_at, updated_at) VALUES ('". $intId ."', '".$dataset{'extDocId'}."', '". $dataset{'extCaseId'}. "', '".$dataset{'nurseOu'}."', '".$dataset{'funcOu'}."', '".$timestamp."', '".$timestamp."')");
        $sth->execute();
        # get the autoincrement primary key of the medical_cases table (we need this as foreign key at the diagnoses table)
        $intCaseId = $dbh_aerzte_ui->last_insert_id(undef,undef,undef,undef);
      }
        
      # check if we have an identical diagnosis already in the diagnoses table
      $sth = $dbh_aerzte_ui->prepare("SELECT id FROM diagnoses WHERE medical_case_id = ".$intCaseId." AND icd10Code = '".$dataset{'icd10Code'}."' AND icd10Text = '".$dataset{'icd10Text'}."' AND icd10Version = '".$dataset{'icd10Version'}."'");
      $sth->execute();
      $count = 0;
      while (my $r = $sth->fetchrow_hashref) {
        $count++;
      }
      if (! $count) {
        # insert the diagnoses part in the diagnoses table (only if there is a diagnosis at all)
        if ($dataset{'icd10Code'}) {
          $sth = $dbh_aerzte_ui->prepare("INSERT INTO diagnoses (medical_case_id, extDocId, icd10Code, icd10Text, icd10Version, created_at, updated_at) VALUES ('". $intCaseId ."', '".$dataset{'extDocId'}."', '". $dataset{'icd10Code'}. "', '". $dataset{'icd10Text'}. "', '". $dataset{'icd10Version'}. "', '".$timestamp."', '".$timestamp."')");
          $sth->execute();
        }
      }

      $sth->finish();
      # ok, we're done with the aerzte_ui
      #$dbh_aerzte_ui->disconnect();
    }
    
    ###
    ### new notification algorithm (contact trial personell according to lookup table in module "s3u config")
    ###
    
    elsif ($dataset{'nurseOu'}) {
      foreach (@wards) {
        my %h = %{$_};
        if ($dataset{'nurseOu'} eq $h{'name'}) {
          foreach (@contacts) {
            my %i = %{$_};
            if ($h{'id'} eq $i{'ward_id'}) {
              $log->debug("identified treating personell for current medical case: ward $h{'name'}, personell $i{'name'}, mail $i{'mail'}");
              # somewhere around here, we will have to send the actual notification mails
            }
          }
        }
      }
    }
    else {
      # oh nooo, epic fail! we miss a patient because no physician is associated with it!
      $log->info("warning: we missed a patient because no physician is associated with it!");
    }
  }
  # horray, we're done, let's get a beer :)
  $dbh_aerzte_ui->disconnect();
  $dbh_hl7interface->disconnect();
}

#
# check for news
#

my $dbh_aerzte_ui = DBI->connect($S3U_CONF{DB_DSN_WEBINTERFACE}, $S3U_CONF{DB_USER_WEBINTERFACE}, $S3U_CONF{DB_PASSWORD_WEBINTERFACE});
$dbh_aerzte_ui && $log->info("4/... success: webinterface connection") || die $log->error("3/... failure: webinterface connection " . DBI::errstr);
$sth = $dbh_aerzte_ui->prepare(
#  "SELECT DISTINCT(p.extDocId) FROM patients p, medical_cases m, diagnoses d, users u WHERE u.extDocId = p.extDocId AND u.current_sign_in_at < '". $timestamp ."' AND ( p.created_at = '" . $timestamp . "' OR m.created_at = '" . $timestamp . "' OR d.created_at = '" . $timestamp . "' )"
  "SELECT DISTINCT(p.extdocid) FROM patients p, medical_cases m, diagnoses d WHERE d.medical_case_id = m.id AND m.patient_id = p.id AND ( p.read_status IS NULL OR m.read_status IS NULL OR d.read_status IS NULL )"
);
$sth->execute();
$log->debug("preparing to send physician notification mail");
while (my $r = $sth->fetchrow_hashref) {
  $log->debug("physician notification mail sent to: " . $r->{'extDocId'});
  buildPhysicianMail($r->{'extDocId'});
}
$sth = $dbh_aerzte_ui->prepare(
  #"SELECT DISTINCT(p.trial_id) FROM patients p, medical_cases m, diagnoses d, users u WHERE u.extDocId = p.extDocId AND u.current_sign_in_at < '". $timestamp ."' AND ( p.created_at = '" . $timestamp . "' OR m.created_at = '" . $timestamp . "' OR d.created_at = '" . $timestamp . "' )"
  "SELECT DISTINCT(p.trial_id) FROM patients p, medical_cases m, diagnoses d WHERE d.medical_case_id = m.id AND m.patient_id = p.id AND ( p.read_status IS NULL OR m.read_status IS NULL OR d.read_status IS NULL )"
);
$sth->execute();
my @trial_ids = ();
while (my $r = $sth->fetchrow_hashref) {
  push @trial_ids, $r->{'trial_id'};
}
$dbh_aerzte_ui->disconnect();

$dbh_studienmonitor = DBI->connect($S3U_CONF{DB_DSN_STUDIENMONITOR}, $S3U_CONF{DB_USER_STUDIENMONITOR}, $S3U_CONF{DB_PASSWORD_STUDIENMONITOR});
$dbh_studienmonitor && $log->info("2/... success: studienmonitor connection") || die $log->error("2/... failure: studienmonitor connection " . DBI::errstr);

if (@trial_ids) {
  $sth = $dbh_studienmonitor->prepare(
    "SELECT mailInvestigator, prenameInvestigator, surnameInvestigator, extId FROM trials WHERE id IN (". join(",",@trial_ids) .")");
  $sth->execute();
  $log->debug("preparing to send trials notification mail ");
  while (my $r = $sth->fetchrow_hashref) {
    $log->debug("trials notification mail sent to: " . $r->{'mailInvestigator'});
    buildTrialMail($r->{'mailInvestigator'},$r->{'prenameInvestigator'},$r->{'surnameInvestigator'},$r->{'extId'});
  }  
}
$dbh_studienmonitor->disconnect();



#
# build mail content for treating physicians
# requires one argument: $_[0] = mail address
#
sub buildPhysicianMail {
  my $extDocId = $_[0];
  
  my %options;
  $options{INCLUDE_PATH} = $S3U_CONF{MAIL_TEMPLATE_PATH_PHYSICIAN};
  
  my %template;
  $template{text} = $S3U_CONF{MAIL_TEMPLATE_FILE_PHYSICIAN};
  $template{html} = $S3U_CONF{MAIL_TEMPLATE_FILE_PHYSICIAN};
  
  my $msg = MIME::Lite::TT::HTML->new(
    From => $S3U_CONF{MAIL_SENDER},
#    To => getMailAddress($extDocId),
    To => $S3U_CONF{DEBUG_MAIL_RECIPIENT},
    Subject => '[S3U][Versorgungskontext] Übersicht über neue, potentiell rekrutierbare Patienten',
    Template => \%template,
    TmplOptions => \%options,
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
sub buildTrialMail {
  my $trialPersonnel = $_[0];
  
  my %params;
  $params{prename} = $_[1];
  $params{surname} = $_[2];
  $params{trial} = $_[3];
  
  my %options;
  $options{INCLUDE_PATH} = $S3U_CONF{MAIL_TEMPLATE_PATH_PHYSICIAN};
  
  my %template;
  $template{text} = $S3U_CONF{MAIL_TEMPLATE_FILE_TRIAL};
  $template{html} = $S3U_CONF{MAIL_TEMPLATE_FILE_TRIAL};
  
  my $msg = MIME::Lite::TT::HTML->new(
    From => $S3U_CONF{MAIL_SENDER},
#    To => $trialPersonnel,
    To => $S3U_CONF{DEBUG_MAIL_RECIPIENT},
    Subject => '[S3U][Forschungskontext] Übersicht über neue, potentiell rekrutierbare Patienten',
    Template => \%template,
    TmplOptions => \%options,
    TmplParams => \%params,
    Charset => 'utf-8',
    Encoding => 'quoted-printable'
  );
  $msg->send();
  #print $msg->as_string;
}

# has to be called like this: getMailAddress($dataset{'extDocId'});
sub getMailAddress {
  my $extDocId = $_[0];

  my $ldap = Net::LDAP->new($S3U_CONF{LDAP_SERVER});

  my $mesg = $ldap->bind($S3U_CONF{LDAP_USER}, password => $S3U_CONF{LDAP_PASSWORD});
  $mesg = $ldap->search(base => $S3U_CONF{LDAP_BASEDN}, filter => "(&(employeeID=".$extDocId."))", attrs => ['mail']);
  $mesg->code && die $log->error("search failed: " . $mesg->error);
  
  if ($mesg->entries) {
    my @results = $mesg->entries;
    # for now just get the first mail address found
    return $results[0]->get_value('mail');
  }
  else {
    # did not find any mail addresses for this ldap user!
    $log->error("Cannot notify physicican: No corresponding mail address found in Active Directory!");
  }
  $mesg = $ldap->unbind;
}