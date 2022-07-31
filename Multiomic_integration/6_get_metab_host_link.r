# input:
# "metabo2host.txt" - metabolite to host targets mapping file from previous step
# "metab_host.txt" - metabolome and host transcriptome correlation results from HAllA

# output:
# "metab_host_link.txt" - metabolome and host transcriptome correlation results with biological links added



library(data.table)
library(dplyr)

metabo.gene_df <- fread("metabo2host.txt",data.table = F, 
                        col.names = c("Metabo","CIDm","Gene","Score","Type"))
corr_df <- fread("metab_host.txt", data.table = F, 
                 col.names = c("Gene","Metabo","r","p"))
results <- merge(corr_df, metabo.gene_df, by=c("Gene", "Metabo"))  %>% 
  select(-CIDm) %>% 
  relocate(Metabo)
results <- results[complete.cases(results),]


write.table(results, file = "metab_host_link.txt", sep = "\t", quote = F, 
            row.names = F, col.names = F)
