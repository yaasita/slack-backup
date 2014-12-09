#!/usr/bin/perl
use strict;
use warnings;

use Encode;
use Data::Dumper;
#print Dumper [1, 2, 3];

my %users;

open (my $fh, "<", 'raw/user_list.txt') or die $!;
{
    my ($id,$name);
    while(<$fh>){
        if (/"id": "(\w+)"/){
            $id = $1;
        }
        elsif (/"name": "([\w\-\.]+)"/){
            $name = $1;
            $users{$name}=$id;
        }
    }
}
close $fh;

open (my $wr, ">", 'hash/users.txt') or die $1;
for (keys %users){
    print $wr "$_:$users{$_}\n";
}
close
