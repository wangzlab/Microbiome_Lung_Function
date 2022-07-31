## Step 1: This step generates table to be analyzed for FEV1 changepoints ##

open (IN, "aeris_by_subj.txt"); ## AERIS lung function data
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
open (IN, "aeris_sample.txt"); ## AERIS microbiome samples 
while (<IN>) {
	chop;
	@a=split("\t",$_);
	next if (/Exac/);
	$sample{"South-".$a[3]}{$a[4]}=$a[0];
}
open (IN, "aeris_matchlist"); ## AERIS microbiome-database ID matches
while (<IN>) {
	chop;
	@a=split("\t",$_);
	$match{$a[1]}=$a[0];
}
for my $key (keys %hash) { ## Subject-level FEV1 data created with microbiome information noted
	open (OUT, ">tables/$key.txt");
	print OUT "Timepoint\tMicrobiome\tTime_Dist\tFEV1\n";
	for my $key2 (sort {$a<=>$b} keys %{$hash{$key}}) {
		next if ($hash{$key}{$key2} eq "");
		next unless ($key2 == 5 or $key2 ==30 or $key2 == 60 or $key2 == 90 or $key2 == 120 or $key2 == 150 or $key2 == 180 or $key2 == 240);
		$microbiome=();
		if (exists $sample{$key}{$key2}) {
			$microbiome=$match{$sample{$key}{$key2}};
			$datedist=0;
		}
		else {
			if (exists $sample{$key}) {
			for my $key3 (keys %{$sample{$key}}) {
					if (abs($key3-$key2)<=10) {
						$microbiome=$match{$sample{$key}{$key3}};
						$datedist=abs($key3-$key2);
						last;
					}
				}
			}
		}
		print OUT $key2."\t".$microbiome."\t".$datedist."\t".$hash{$key}{$key2}."\n";
	}
}