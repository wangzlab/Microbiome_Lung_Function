# input:
# "contrib.txt" - micro-EC contribution from previous step
# "currency_cmpd.txt" - 'currency' compound list to be removed from analysis
# "ec2metabo.txt" - ec to metabolites from previous step
# "micro_metab.txt" - microbiome and metabolome correlation results from HAllA


# output:
# "micro_metab_link.txt" - microbiome and metabolome correlation results with biological link information added
# 

library(data.table)
library(dplyr)


contribution <- fread("contrib.txt");colnames(contribution) <- c( "OTU","EC","contribution")
contribution$EC <- gsub(":","-",contribution$EC )

curre.cmpds <- fread("currency_cmpd",header = F)$V1

ec.metabo_df <- fread("ec2metabo.txt",data.table = F,header = F, select = 1:4,
                      col.names = c("EC","Cmpd","Type","Metabo"))


corr_df <- fread("micro_metab.txt",header = F, col.names = c("Metabo","OTU","r","p"))


# obtain ECs to which the OTUs contribute 

EC.byOTU_list <- sapply(unique(corr_df$OTU),
                     function(x){
                       if(x %in% contribution$OTU){
                         contribution$EC[which(contribution$OTU == x)]
                       }else NA
                     })

# obtain metabos which has a connection to the ECs

results.combined <- NULL
for(i in c(1:length(EC.byOTU_list))){
  # i=1
  
  otu = names(EC.byOTU_list)[i]
  
  ecs <- EC.byOTU_list[[i]]
  
  # metabos in correlaiton df
  # metabos.corr <- corr_df$Metabo[which(corr_df$OTU == otu)]
  
  # metabos with a reaction to ECs
  rxn_df <- ec.metabo_df %>% 
    filter(!Cmpd %in% curre.cmpds) %>%
    filter(EC %in% ecs) %>%
    filter(!is.na(Metabo)) %>%
    select(EC, Type, Metabo) %>%
    unique()
  
  if(nrow(rxn_df) == 0) next
  
  res_c <- merge(corr_df %>% filter(OTU == otu),
        rxn_df,
        by = 'Metabo') %>% relocate(OTU) %>% unique() 
  
  # unique the connections
  connections <- paste(res_c$OTU, res_c$Metabo, res_c$EC, sep="|")
  dup_connections <- connections[which(duplicated(connections))]
  
  dup_rows <- which(connections %in% dup_connections)
  res_c$Type[dup_rows] <- "Product_And_Substrate"
  
  res_c <- res_c %>% unique()
  
  results.combined <- bind_rows(results.combined, res_c)
}


write.table(results.combined, file = "micro_metab_link.txt",
            sep = "\t", col.names = F, row.names = F,quote = F)
