#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use Scalar::Util qw(reftype);


my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->default_header( 'Accept' => 'application/json' );


my %task_id=();
my %cath_id=();


open (INPUTFILE, "<", "../Files/seq_antigens_151.fasta") || die("ERROR: Can't open file: $!\n");
my $sequence="";
my %data=();
my $n=0;
my $id="";

while (my $line=<INPUTFILE>){
  
    if ($line=~/^>(\S+)/) {
    
        chomp($line);
        
        $id=$line;
        
        if ($n>0) {
            
            
            
            my $id_key=($id);
            
            
            &take_task_id($sequence, $id_key); ##qui mandiamo la prima url per i task id
            
            $n=0;
        }
        $sequence.=$line;
        $n++;
    }else {
	    $sequence.=$line;
	}
}

&take_task_id($sequence, $id); ####qui lanciamo query 1 per il task id dell'ultimo fasta

close INPUTFILE;

###scriviamo su un file i task id delle rischieste che abbiamo fatto cosi poi ce le andiamo a riprendere dopo un pò
open (TASK, ">", "../Files/task_ids.csv") ;
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
    
    my $url = 'http://www.cathdb.info/search/by_funfhmmer';
    my $response = $ua->post( $url , \%data );
    print $response->is_success."\n";
    my $task="";
    if ( $response->is_success ) {
        
        my $res= $response->decoded_content;
        $res =~ s/[\$#@~!&*()\[\];.,?^ \"\{\}`\\\/]+//g;
        my @pippo=split(/\:/,$res);            
        $task=$pippo[1];
        
        $task_id{$id_s}=$task;   ###mettiamo i task id in un hash con chiave= fasta id, valore= task id
    }else {
        print "no task id!\n";
        die $response->status_line;
    } 
}
