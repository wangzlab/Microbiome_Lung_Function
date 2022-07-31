Time-series analysis to identify change-points for FEV1 and associate them with microbiome in AERIS cohort.

1_generate_tables.pl: This step generates table to be analyzed for FEV1 changepoints.

2_PELT.pl: This step calls PELT method to identify changepoint for each subject.

3_get_changepoint.pl: This step parses raw changepoint results into tables.

4_zscore_calc.pl: This step calculates within-individual enrichment z-score for each taxa in changepoints against non-changepoints.

5_perm_reshuffle.pl: This step reshuffles changepoints 100 times to obtain permutation background.

6_perm_zscore_calc.pl: This step calculates enrichment z-score for each taxa in changepoints against non-changepoints for the permutation background.
