# input:
# "final_CIDm.txt" - metabolite IDs to CIDm IDs mapping file
# "all_cidm_receptor.txt" - CIDm to host target mapping file derived from STITCH

# output:
# "metabo2host.txt" - metabolites to host gene mapping file

library(data.table)
library(dplyr)


metabo.CIDm_df <- fread("final_CIDm.txt", data.table = F, header = F, col.names = c("Metabo","CIDm"))
dat <- fread("all_cidm_receptor.txt",data.table = F,
             fill=TRUE, header = F,sep = "\t")
# correct the all_cidm_receptor data frame errors due to mis-positionning 
for(i in c(1:nrow(dat))){
  
  #i=1
  
  if(!dat$V5[i] %in% c("binding","inhibition", "activation","catalysis","expression","reaction") & dat$V3[i] == ""){
    dat[i,4:10] <- dat[i,3:9]
  }
} 
cidm_receptor <- dat %>%
  #filter(V2 != "") %>% 
  filter(V3 != "") %>% 
  filter(!is.na(V10))  %>% 
  select(c(1,3,5,10))

metabo2host <- 
  merge(metabo.CIDm_df, cidm_receptor, by.x="CIDm", by.y="V1") %>%
  relocate(Metabo, CIDm, V3, V10, V5) 


write.table(metabo2host, file = "metabo2host.txt", 
            sep = '\t', quote = F,
            row.names = F, col.names = F)
