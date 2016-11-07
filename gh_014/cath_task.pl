#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use Scalar::Util qw(reftype);

use FindBin;        # core:     no need to install
use Data::Dumper;   # core:     no need to install
use JSON::MaybeXS;  # non-core: need to install via CPAN or (cpanm)

my $IN_FILE  = "$FindBin::Bin/seq_antigens_151.fasta";
my $OUT_FILE = "$FindBin::Bin/task_ids.csv";
my $URL_BASE = "http://www.cathdb.info/search/by_funfhmmer";
my $JSON = JSON::MaybeXS->new();

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->default_header( 'Accept' => 'application/json' );


my %task_id=();
my %cath_id=();


open (INPUTFILE, "<", $IN_FILE ) || die("ERROR: Can't open file: $!\n");
my $sequence="";
my %data=();
my $last_id="";

while (my $line=<INPUTFILE>){

  chomp($line);

  if ( $line=~/^>(\S+)/ ) {
      my $next_id = $1;
      # if we already have a sequence then submit this
      # before moving on to the next id
      if ( $sequence ) {
          &take_task_id($sequence, $last_id); ##qui mandiamo la prima url per i task id
          $sequence = '';
      }
      $last_id = $next_id;
  }
  else {
      $sequence .= $line;
	}
}

if ( $sequence ) {
  &take_task_id($sequence, $last_id); ####qui lanciamo query 1 per il task id dell'ultimo fasta
}

close INPUTFILE;

###scriviamo su un file i task id delle rischieste che abbiamo fatto cosi poi ce le andiamo a riprendere dopo un pò
open (TASK, ">", $OUT_FILE) ;
foreach my $key (keys %task_id){
    ### print key , value
    print TASK $key.",".$task_id{$key}."\n";
}
close TASK;

####################################################################################
####FUNZIONI##########################################
sub take_task_id{
    my $sequence=$_[0];
    my $id_s=$_[1];
    my $count=0;
    my %data=();

    $data{fasta} = $sequence;

    warn "Sending sequence: `$sequence`\n";

    my $url = $URL_BASE;
    my $response = $ua->post( $url , \%data );
    print $response->is_success."\n";
    my $res = $response->decoded_content;
    my $task="";

    if ( $response->is_success ) {
        $res =~ s/[\$#@~!&*()\[\];.,?^ \"\{\}`\\\/]+//g;
        my @pippo=split(/\:/,$res);
        $task=$pippo[1];

        $task_id{$id_s}=$task;   ###mettiamo i task id in un hash con chiave= fasta id, valore= task id
    } else {
        my $data = JSON::Any->from_json( $res );
        my $err = $data->{error};
        print "no task id!\n";
        die $response->status_line . ": ". $err;
    }
}
