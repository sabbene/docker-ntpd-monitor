#!/usr/bin/env perl

use strict;
use warnings;

#https://www.ntppool.org/user/c2gnfzfctso6pbb9hqsr4

my $time    = localtime;
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
my $ip_link;
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
    $ip_link    = $url."scores/".$ip;
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
    $data{$ip}{ip_link}   = $ip_link;
    $data{$ip}{"score"}    = $score;
    $data{$ip}{"note"}     = $note;
  }
}

for my $key ( keys %data ) {
  print "$data{$key}{hostname} (<a href=$data{$key}{ip_link}>$data{$key}{ip}</a>): $data{$key}{note} ($data{$key}{score})<br>\n";
  print "<a href=$data{$key}{ip_link}><img src=\"$data{$key}{graph}\"></a><br>\n";
}
print "<br><br>Last updated: $time<br>";
