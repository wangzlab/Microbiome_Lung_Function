# Step 5: reshuffle FEV1 changepoints 100 times as permutation background ##

use List::Util qw/shuffle/;

open (IN, "all_changepoints.txt"); ## the concatenated changepoints for all individuals
while (<IN>) {
	chop;
	@a=split("\t",$_);
	push @{$sample{$a[0]}}, $a[3];
	push @{$changepoint{$a[0]}}, $a[6];
	$hash{$a[0]}{$a[3]}=$a[7];
}
for my $count (1..100) {
	system ("mkdir perm_$count");
	for my $key (sort keys %hash) {
		open (OUT, ">perm_$count/$key.txt");
		@tmp=shuffle @{$sample{$key}};
		@tmp2=@{$changepoint{$key}};
		#print $#tmp."\t".$#tmp2."\n";
		for my $i (0..$#tmp) {
			print OUT $tmp[$i]."\t".$tmp2[$i]."\t".$hash{$key}{$tmp[$i]}."\n";
		}
	}	
}
