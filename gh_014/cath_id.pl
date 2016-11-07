#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use Scalar::Util qw(reftype);


my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->default_header( 'Accept' => 'application/json' );


open (INPUTFILE, "<", "../Files/task_ids.csv") || die("ERROR: Can't open file: $!\n");
while(<INPUTFILE>){
    my @fields=split(",",$_);
    my $antigen_id=$fields[0];
    my $task_id=$fields[1];
    &take_cath_id($antigen_id, $task_id);
}
close INPUTFILE;


sub take_cath_id{
    my $antigen_id=shift;
    my $task_id=shift;
    
    my $url = "http://www.cathdb.info/search/by_funfhmmer/results/".$task_id; 
    
    my $response = $ua->get( $url );
    if ( $response->is_success ) {
        my @strsplit = split(/\,/, $response -> decoded_content);
        for my $i (0 .. $#strsplit){
            my $prova = $strsplit[$i];  
            if($prova =~ /(\d\.\d{2}\.\d{2}\.\d{3}).*/){
                my $ciccio = $1;
                #print $ciccio."\n";
                #"NoRecognition" =~ /(NoRecognition)/;
            }
            if($prova =~ /(\d\.\d{2}\.\d{3}\.\d{1}).*/){
                my $ciccio = $1;
                # print $ciccio."\n";
                #"NoRecognition" =~ /(NoRecognition)/;
            }
            if($prova =~ /(\d\.\d{2}\.\d{2}\.\d{2}).*/){
                my $ciccio = $1;
                #print $ciccio."\n";
                #"NoRecognition" =~ /(NoRecognition)/;
            }
        }
    }else{
        print $antigen_id." Vediamo un po'"."\n";
        die $response->status_line;
    }
}

        
