# Step 3: Parse raw changepoint results into a new directory #

open (IN, "samplelist");
while (<IN>) {
	chop;
	$id=$_;
	my %tps=();
	open (IN1, "results/$id.txt");
	while (<IN1>) {
		chop;
		next unless (/Changepoint Locations\s+\:\s+(.+)/);
		@changepoints=split(" ",$1);
		for my $val (@changepoints) {
			$tps{$val}=1;
			#print $val."\n";
		}
	}
	open (IN2, "tables/$id.txt");
	open (OUT, ">changepoints/$id.txt");
	$dump=<IN2>;
	chop $dump;
	print OUT $dump."\tChangepoint\n";
	$count=1;
	while (<IN2>) {
		chop;
		if (exists $tps{$count}) {
			print OUT $_."\tY\n";
		}
		else {
			print OUT $_."\tN\n";
		}
		$count++;
	}
}
