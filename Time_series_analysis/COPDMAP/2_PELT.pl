# Step 2: call PELT method to identify changepoint for each subject #
open (IN, "samplelist"); ## aeris_sample_list
while (<IN>) {
	chop;
	$id=$_;
	system ("Rscript PELT.R tables/$id.txt results/$id.txt");
}