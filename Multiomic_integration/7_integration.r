# Input
# "micro_metab_link.txt" - results from previous step
# "mapping.txt" - species ID to taxonomy mapping file
# "metabolome_desc.txt" - metabolite description file
# "metab_host_link.txt" - results from previous step
# "metab_fc_pval.txt" - metabolite FC and P-values from RD/SD/ND
# "host_fc_pval.txt" - host gene FC and P-values from RD/SD/ND

# Output
# results <- fread("micro_metab_host_select.txt")


library(data.table)
library(dplyr)

OTU.Metabo.link <- fread("micro_metab_link.txt", data.table = F, 
                         col.names = c("Micro","MetaB","Micro_MetaB_Cor","Micro_MetaB_Pval","EC","Type"))
OTU.mapping <- fread("mapping", data.table = F,header = F,sep = "\t", col.names = c("Micro","Species"))

Metabo.descr <- fread("desc.txt", data.table = F)

Metabo.Gene.link <- fread("metab_host_link.txt", data.table = F,
                          col.names = c("MetaB","HostT","MetaB_HostT_Cor","MetaB_HostT_Pval","Score","Type"))

Metabo.fc <- fread("metab_fc_pval", data.table = F)
Host.fc <- fread("host_fc_pval", data.table = F)


# filter OTU-metabo links ---------------
OTU.Metabo.link.selected <- OTU.Metabo.link %>%
  filter(Micro_MetaB_Pval < 0.1) %>% 
  filter(!(Micro_MetaB_Cor < 0  & Type == "Product")) %>% 
  filter(!(Micro_MetaB_Cor > 0  & Type == "Substrate")) %>% 
  select(-EC, -Type) %>%
  unique() 


# combine the data frames  ---------------
tmp1 <- merge(OTU.Metabo.link.selected,
              Metabo.Gene.link %>% select(-Score, -Type) %>% filter(MetaB_HostT_Pval < 0.25),
      by = "MetaB") 

tmp2 <- merge(tmp1, Metabo.fc, by.x = "MetaB", by.y = "V1") %>%
 # filter(raw.pval < 0.25 ) %>%
  mutate(MetaB_FC = FC) %>%
  select(-FC, -`log2(FC)`, -raw.pval)


tmp3 <- merge(tmp2, Host.fc, by.x = "HostT", by.y = "Symbols") %>%
  filter(PValue < 0.05 ) %>%
  mutate(HostT_FC.log = logFC) %>%
  select( -logFC, -PValue)



results <- tmp3 %>%
  mutate(Taxon = sapply(Micro, function(x) OTU.mapping$Species[which(OTU.mapping$Micro == x)])) %>%
  mutate(Metabolite =  sapply(MetaB, function(x) Metabo.descr$Description[which(Metabo.descr$Metabolite == x)])) %>%
  relocate(Micro, MetaB, HostT, Micro_MetaB_Cor,Micro_MetaB_Pval,  MetaB_HostT_Cor,MetaB_HostT_Pval,Taxon,Metabolite,
           MetaB_FC, HostT_FC.log)


write.table(results, file="micro_metab_host_select.txt",sep = "\t", quote = F, row.names = F)
