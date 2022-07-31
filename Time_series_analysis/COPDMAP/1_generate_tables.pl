## Step 1: This step generates table to be analyzed for FEV1 changepoints ##

open (IN, "copdmap_by_subj.txt"); ## COPDMAP lung function data
$header=<IN>;
chop $header;
@headers=split("\t",$header);
while (<IN>) {
	chop;
	@a=split("\t",$_);
	for my $i (1..$#a) {
		$hash{$a[0]}{$headers[$i]}=$a[$i];
	}
}
open (IN, "timepts.txt"); ## COPDMAP time points data
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$timepoint{$a[0]}{$a[2]}=$a[3];
}
open (IN, "copdmap_matchlist"); ## COPDMAP microbiome database ID matchlist
while (<IN>) {
	chop;
	@a=split("\t",$_);
	next if (/Exacerbation/);
	$sample{$a[3]}{$a[2]}=$a[0];
}
for my $key (keys %hash) { ## Subject-level FEV1 data created with microbiome information noted
	open (OUT, ">tables/$key.txt");
	print OUT "Timepoint\tDate\tMicrobiome\tDate_dist\tFEV1\n";
	for my $key2 (sort {$a<=>$b} keys %{$hash{$key}}) {
		next if ($hash{$key}{$key2} eq "");
		$microbiome=();
		$datedist=();
		if (exists $sample{$key}{$timepoint{$key}{$key2}}) {
			$microbiome=$sample{$key}{$timepoint{$key}{$key2}};
			$datedist=0;
		}
		else {
			if (exists $sample{$key}) {
				for my $key3 (keys %{$sample{$key}}) {
					if (abs($key3-$timepoint{$key}{$key2})<=60) {
						$microbiome=$sample{$key}{$key3};
						$datedist=abs($key3-$timepoint{$key}{$key2});
						last;
					}
				}
			}
		}
		print OUT $key2."\t".$timepoint{$key}{$key2}."\t".$microbiome."\t".$datedist."\t".$hash{$key}{$key2}."\n";
	}
}
