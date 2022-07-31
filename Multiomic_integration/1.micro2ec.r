# input: 
# "asv.txt"
# "mapping"
# "micro"
# "pred_metagenome_strat.tsv"
# "meta.txt"

# output:
# "ec.txt"
# "contrib.txt"


library(data.table)
library(dplyr)



# ASV - species connection -------------------
ASV.spec_df <- fread("asv.txt", data.table = F, sep = "\t", header = F, col.names = c("ASV","species"))
ASV.spec_df$species <- gsub("; ",";",ASV.spec_df$species)

# OTU - species connection ------------------
OTU.spec_df <- fread("mapping", data.table = F, sep = '\t', header = F, col.names = c("OTU","species"))

# OTU list -----------------------
otus <- fread("micro", data.table = F,header = F, col.names="OTU")
# otus <- as.data.frame( c("OTU18",  "OTU143", "OTU369")); colnames(otus)<-"OTU" # debug



# calculate ASV contribution to EC -------------------

taxon.list <- 
  merge(OTU.spec_df %>% filter(OTU %in% otus$OTU),
        ASV.spec_df, by = "species")

# calculate contribution ------------------------
meta <- fread("meta.txt")

# load("pred_metagenome_strat.tsv.RData")
dat <- fread("pred_metagenome_strat.tsv",data.table=F)

 
# dat[1:6,1:6]
dat <- dat %>% filter(sequence %in% taxon.list$ASV) %>%
  select(`function`,sequence, all_of(meta$`#SampleID`))
EC.ASV.contri <-
  cbind.data.frame(
    EC=dat$`function`,
    ASV=dat$sequence,
    contri=apply( dat[,3:ncol(dat)], 1, sum),
    stringsAsFactors=F
  ) 
remove(dat)
gc()

EC.ASV.contri <- EC.ASV.contri %>% filter(contri > 0)



# species contribution to EC 

EC.taxon.contri <- merge(taxon.list, EC.ASV.contri, by="ASV")

EC.species.contri <- EC.taxon.contri %>% 
  group_by(species, OTU, EC) %>%
  summarise(contribution = sum(contri))


# Export EC list -----
EC.list <- as.data.frame(unique(EC.species.contri$EC)[order(unique(EC.species.contri$EC))])
write.table(EC.list, file = "ec.txt", sep = "\t", row.names = F, col.names = F, quote = F)


# Export Species contribution to EC ------------
write.table(EC.species.contri %>% as.data.frame() %>% select(-species),
            sep="\t", quote = F, row.names = F, col.names = F,
            file = "contrib.txt")
