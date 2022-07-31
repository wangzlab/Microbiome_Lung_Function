## Step 4: Calculate within-individual enrichment z-score for each taxa in changepoints against non-changepoints

use lib "/home/wangzhang/perl5/lib/perl5/";
use Statistics::Descriptive;

open (IN, "taxa_matchlist");
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$matchlist{$a[1]}=$a[0];
}
open (IN, "AERIS_L6_asinsqrt.txt");
open (OUT, ">AERIS_L6.txt_match");
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
		$hash{"Taxa".$count}{"AERIS_".$headers[$i]}=$a[$i];
		$transhash{"AERIS_".$headers[$i]}{"Taxa".$count}=$a[$i];
	}
	$count++;
}
for my $key (keys %hash) {
	next unless (exists $matchlist{$match{$key}});
	open (IN, "sublist");
	while (<IN>) {
		chop;
		$id=$_;
		my @nochange=();
		my @change=();
		open(IN1, "../changepoints/$id.txt");
		while (<IN1>) {
			chop;
			@a=split("\t",$_);
			next unless ($a[1] =~ /AERIS/);
			if ($a[4] eq 'N') {
				push @nochange, $hash{$key}{$a[1]};
			}
			if ($a[4] eq 'Y' and $a[5] < 0) {
				push @change, $hash{$key}{$a[1]};
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
