#!/usr/bin/env perl

use strict;
use warnings;

#https://www.ntppool.org/user/c2gnfzfctso6pbb9hqsr4

my $url     = 'https://www.ntppool.org/';
my $user    = 'user/';
my $graph   = 'graph/';
my $png     = '/offset.png';
my $user_id = $ARGV[0];

my @output=qx(curl -s "$url$user$user_id");

my %data;

my $hostname;
my $ip;
my $graph_url;
my $score;
my $note;

for my $line ( @output ) {
  if ( $line =~ /^Hostname\:/ ) {
    $hostname = $line;
    $hostname =~ s/Hostname:\s+.*?\>(.*?)\<.*/$1/;

    chomp $hostname;
  }
  elsif ( $line =~ /^IP\:/ ) {
    $ip = $line;
    $ip =~ s/IP\:\s+.*?\"\>(.*?)\<.*$/$1/;

    chomp $ip;

    $graph_url = "$url$graph$ip$png";
  }
  elsif ( $line =~ /^Current\s+score\:/ ) {
    $score = $line;
    $score =~ s/Current\s+score\:\s+.*?\>(.*?)\<.*$/$1/;

    chomp $score;

    if ( $score < 10 ) {
        $note = 'CRITICAL: score too low for pool';
    }
    else {
        $note = 'OK: host in pool';
    }
  }
  elsif ( $line =~ /noscript/ ) {
    $data{$ip}{"hostname"} = $hostname;
    $data{$ip}{"ip"}       = $ip;
    $data{$ip}{"graph"}    = $graph_url;
    $data{$ip}{"score"}    = $score;
    $data{$ip}{"note"}     = $note;
  }
}

for my $key ( keys %data ) {
  print "$data{$key}{hostname} ($data{$key}{ip}): $data{$key}{note} ($data{$key}{score})<br>\n";
  print "<img src=\"$data{$key}{graph}\"><br>\n";
}
