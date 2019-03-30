#!/usr/bin/env perl

use strict;
use warnings;

print localtime." Starting $0\n";

my $time        = localtime;
my $output_file = '/html/ntpd/index.html';
my $url         = 'https://www.ntppool.org/';
my $user        = 'user/';
my $graph       = 'graph/';
my $png         = '/offset.png';
my $user_id     = $ENV{id};

while ( 1 ) {
  print localtime." checking stats for $user_id\n";
  my @output = qx(curl -s "$url$user$user_id");
  
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
	  print localtime." $ip score is too low for pool ($score)\n";
      }
      else {
          $note = 'OK: host in pool';
	  print localtime." $ip is in pool ($score)\n";
      }
    }
    elsif ( $line =~ /noscript/ ) {
      $data{$ip}{"hostname"} = $hostname;
      $data{$ip}{"ip"}       = $ip;
      $data{$ip}{"graph"}    = $graph_url;
      $data{$ip}{ip_link}    = $ip_link;
      $data{$ip}{"score"}    = $score;
      $data{$ip}{"note"}     = $note;
    }
  }

  open(my $fh, ">", $output_file) or die (localtime." Cannot open $output_file: $!");

  for my $key ( keys %data ) {
    print $fh "$data{$key}{hostname} (<a href=$data{$key}{ip_link}>$data{$key}{ip}</a>): $data{$key}{note} ($data{$key}{score})<br>\n";
    print $fh "<a href=$data{$key}{ip_link}><img src=\"$data{$key}{graph}\"></a><br>\n";
  }
  print $fh "<br><br>Last updated: $time<br>";

  close ($fh);

  sleep 900;
}
