#!/usr/bin/perl
use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
use Encode;

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

for (<tmp/*>){
    create_archive($_);
}

sub create_archive {
    my $rawfile = shift;
    open (my $fh, "<", $rawfile) or die $!;
    my $archivefile;
    {
        # アーカイブフォルダ作成
        my $channel_id = (split(/\//,$rawfile))[1];
        unless (-e "archive/$channels{$channel_id}"){
            mkdir "archive/$channels{$channel_id}";
        }
        # アーカイブファイル決定
        my $t = localtime;
        $t = $t - ONE_DAY;
        my $yesterday = Time::Piece->strptime($t->strftime('%Y-%m-%d'), '%Y-%m-%d');
        $archivefile = "archive/$channels{$channel_id}/".$yesterday->strftime("%Y-%m-%d").".txt";
    }
    open (my $wr, ">", "$archivefile") or die $!;
    while (<$fh>){
        chomp;
        my $line = $_;
        unless ($line =~ /"text"|"user"|"ts"/) {
            next;
        }
        while ($line =~ /((?:\\u[0-9a-f]{4})+)/g){
            my $hex_string = $1;
            my $utf_string = $1;
            $utf_string =~ s/\\u//g;
            $utf_string = decode("utf-16be",pack("H*",$utf_string) );
            $line =~ s/\Q$hex_string\E/$utf_string/g;
        }
        $line =~ s/^.*"user": "(\w+)".*/$users{$1}\: /;
        $line =~ s/^.*"text"\: "(.+)".+/$1  /;
        $line =~ s/<@(\w+?)>/"@".$users{$1}/e;
        $line =~ s#\\/#/#g;
        my $t = localtime();
        $line =~ s/^.*"ts"\: "(\d+)\.\d+"/$t = Time::Piece->strptime($1, '%s') and $t = $t + ONE_HOUR * 9 and $t->strftime("%Y-%m-%d %H:%M:%S")."\n"/e;
        print $wr encode("utf-8",$line);
    }
    close $fh;
    close $wr;
    # 逆順にする
    open (my $fh2,"<",$archivefile) or die $!;
    my @line = <$fh2>;
    close $fh2;
    open (my $wr2, ">",$archivefile) or die $!;
    for (reverse @line){
        print $wr2 $_;
    }
    close $wr2;
}
