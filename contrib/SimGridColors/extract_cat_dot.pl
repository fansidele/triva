#!/usr/bin/perl
my $input_file = $ARGV[0];

my %node_category;
my %edge_category;

open( FILE, "< $input_file");

while(<FILE>){
  if(/node\s*\[([^\]]*)\];/){
  #part on the default option for nodes
  }elsif (/edge\s*\[([^\]]*)\];/){
  #part on the default option for edge
  }elsif (/^\s*"?([^-"]+)"?\s*(\[([^\]]*)\])?;/){
  #part on the option of a node
    if( $2 =~/category\s*[:=]\s*(\S+)/){
      my $cat = $1;
      $cat = $1 if($cat =~ /"(\S+)"/);
      $node_category{$cat} = 1;
    }
  } elsif (/\s*"?[^-"]*"?\s*->\s*"?[^ -"]*"?\s*\[([^\]]*)\];/){
  #part on the option of a edge
    if( $1 =~/category\s*[:=]\s*(\S+)/){
      my $cat = $1;
      $cat = $1 if($cat =~ /"(\S+)"/);
      $edge_category{$cat} = 1;
    }
  }
}
close(FILE);

foreach (keys %edge_category){
  print $_." ";
}
foreach (keys %node_category){
  print $_."  ";
}
print "\n";

