#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw/ tempfile tempdir /; 
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

my $API_TOKEN = "";
{
    open (my $fh,"<","conf/token.sh") or die $!;
    while (<$fh>){
        chomp;
        $API_TOKEN = $1 if /API_TOKEN=(.*)/;
    }
}

# users,channelsの名前解決用
my (%channels,%users);
{
    open (my $fh,"<","hash/channels.txt") or die $!;
    while (<$fh>){
        chomp;
        my ($name,$id) = split(/:/);
        $channels{$id}=$name;
    }
    close $fh;
}
{
    open (my $fh,"<","hash/users.txt") or die $!;
    while (<$fh>){
        chomp;
        my ($name,$id) = split(/:/);
        $users{$id}=$name;
    }
    close $fh;
}

{
    my $t = localtime;
    $t = $t - ONE_DAY;
    my $yesterday = Time::Piece->strptime($t->strftime('%Y-%m-%d'), '%Y-%m-%d');
    my $today = $yesterday + ONE_DAY;

    my $oldest = $yesterday->strftime("%s");
    my $latest = $today->strftime("%s");
    for ( keys %channels ){
        my $exec_curl = "curl -s 'https://slack.com/api/channels.history?token=${API_TOKEN}&channel=${_}&"
                      . "latest=$latest&oldest=$oldest&count=1000&pretty=1' > tmp/$_";
        print "exec $exec_curl\n";
        my $i=0;
        while ( system $exec_curl ){
            print "sleep 15m ...\n";
            sleep 60*15;
            die "curl error" if $i>=3;
            $i++;
        }
    }
}


