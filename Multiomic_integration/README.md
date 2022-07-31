This repository contains scripts for multi-omic integration in Guangzhou cohort.

1_micro2ec.r: Generate microbiome species-to-EC contribution.

2_ec2cmpd.r: Generate EC to compound linkage information based on MetaCyc.

3_cmpd2metabo.r: Generate metacyc compound to metabolite ID linkage information based on ID mapping or structure match.

4_metabo2host.r: Generate metabolites to host gene linkage information based on STITCH.

5_get_micro_metab_link.r: Generate microbiome and metabolite correlation file with biological link information added.

6_get_metab_host_link.r: Generate metabolite to host transcriptome correlation file with biological link information added.

7_integration.r: Integrate microbiome-metablite-host transcriptome links.
