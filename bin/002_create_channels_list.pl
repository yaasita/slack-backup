#!/usr/bin/perl
use strict;
use warnings;

use Encode;
use Data::Dumper;
#print Dumper [1, 2, 3];

my %channels;

open (my $fh, "<", 'raw/channels_list.txt') or die $!;
{
    my ($id,$name);
    while(<$fh>){
        if (/"id": "(\w+)"/){
            $id = $1;
        }
        elsif (/"name": "([\w\-]+)"/){
            $name = $1;
            $channels{$name}=$id;
        }
    }
}
close $fh;

open (my $wr, ">", 'hash/channels.txt') or die $1;
for (keys %channels){
    print $wr "$_:$channels{$_}\n";
}
close
