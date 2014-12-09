#!/usr/bin/perl
use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
use utf8;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);

my $MAIL_FROM;
my $MAIL_TO;
{
    open (my $fh,"<","conf/token.sh") or die $!;
    while (<$fh>){
        chomp;
        $MAIL_FROM = $1 if /^MAIL_FROM=(.*)/;
        $MAIL_TO   = $1 if /^MAIL_TO=(.*)/;
    }
}

my $copy_date;
{
    if (defined $ARGV[0]){
        $copy_date = shift;
    }
    else {
        my $t = localtime;
        $t = $t - ONE_DAY;
        my $yesterday = Time::Piece->strptime($t->strftime('%Y-%m-%d'), '%Y-%m-%d');
        $copy_date = $yesterday->strftime("%Y-%m-%d");
    }
}

# copy
{
    open (my $find, '-|', "find ./archive -name $copy_date.txt") or die $!;
    while (<$find>){
        chomp;
        my $source = $_;
        # 元のテキスト読み込み
        open (my $text,"<",$source) or die $!;
        my $source_data = do { local $/; <$text> };
        close $text;
        # メールにして書き出し
        my $mailfile = $source;
        $mailfile =~ s#./archive/([\w\-]+)/(.+)\.txt#mail/$1.$2.eml#;
        my $channel = $1;
        my $date = $2;
        open (my $mail,">",$mailfile) or die $!;
        print $mail &mail_heder($channel,$date);
        print $mail encode_base64($source_data);
        close $mail;
        #print "$source => $mailfile\n";
    }
}

sub mail_heder {
    my $date;
    my $mail_from = $MAIL_FROM;
    my $channel = shift;
    my $hiduke = shift;
    {
        $ENV{'TZ'} = "JST-9";
        my ($sec,$min,$hour,$mday,$mon,$year,$wday) = localtime(time);
        my @week = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
        my @month = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
        $date = sprintf("%s, %d %s %04d %02d:%02d:%02d +0900 (JST)", $week[$wday],$mday,$month[$mon],$year+1900,$hour,$min,$sec);
    } 
    my $subject = `echo "slackログ $channel $hiduke" | nkf -W -M -w`;
    chomp $subject;
    my $message_id = md5_hex($subject) . "."  . time() . "." . $mail_from;
    my $head = <<"HEADER";
From: $mail_from
To: $MAIL_TO
Content-Type: text/plain; charset=UTF-8
Message-Id: <$message_id>
Date: $date
Subject: $subject
Content-Transfer-Encoding: Base64

HEADER
    return $head;
}
