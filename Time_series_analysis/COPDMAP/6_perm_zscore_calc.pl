# Step 6: Obtain enrichment z-score for each taxa in changepoints against non-changepoint for the permutation background data 

use lib "/home/wangzhang/perl5/lib/perl5/";
use Statistics::Descriptive;

open (IN, "taxa_matchlist");
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$matchlist{$a[1]}=$a[0];
}
open (IN, "COPDMAP_L6_asinsqrt.txt");
$header=<IN>;
chop $header;
@headers=split("\t",$header);
$count=1;
while (<IN>) {
	chop;
	@a=split("\t",$_);
	print OUT $a[0]."\t"."Taxa$count\n";
	$match{"Taxa".$count}=$a[0];
	for my $i (1..$#a) {
		$hash{"Taxa".$count}{"COPDMAP_".$headers[$i]}=$a[$i];
		$transhash{"COPDMAP_".$headers[$i]}{"Taxa".$count}=$a[$i];
	}
	$count++;
}
$num=$ARGV[0]; ## input 1 to 100
for my $key (sort keys %hash) {
	next unless (exists $matchlist{$match{$key}});
	open (IN, "../sublist");
	while (<IN>) {
		chop;
		$id=$_;
		my @nochange=();
		my @change=();
		open (IN1, "perm_$num/$id.txt");
		while (<IN1>) {
			chop;
			@a=split("\t",$_);
			#print $matchlist{$match{$key}}."\t".$_."\n";
			next unless ($a[0] =~ /COPDMAP/);
			if ($a[1] eq 'N') {
				push @nochange, $hash{$key}{$a[0]};
			}
			if ($a[1] eq 'Y') {
				push @change, $hash{$key}{$a[0]};
			}
		}
		my $stat = Statistics::Descriptive::Full->new();
		$stat->add_data(@nochange);
		$mean=$stat->mean();
		$stdev=$stat->standard_deviation();
		if ($stdev==0) {
			$k=0;
			$j=0;
			for my $val (@change) {
				$k+=$val;
				$j++;	
			}
			$aver=$k/$j;
			if ($aver>$mean) {
				$averzscore="Greater";
			}
			elsif ($aver==$mean) {
				$averzscore="Equal";
			}
			else {
				$averzscore="Smaller";
			}
		}
		else {
			$zscore=0;
			$i=0;
			for my $val (@change) {
				$zscore += ($val-$mean)/$stdev;
				$i++;
			}
			$averzscore=$zscore/$i;
		}
		print $matchlist{$match{$key}}."\t".$id."\t".$averzscore."\n";	
	}
}
