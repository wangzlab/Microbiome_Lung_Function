# input:
# "ec2cmpd.txt": - ec to metacyc compound mapping file from last step
# "cmpd2metabo.txt" - metacyc compound to metabolites (in metabolomic data) manually curated

# output:
# "ec2metabo.txt" - ec to metabolites mapping file

library(data.table)
library(dplyr)

ec.cmpd_df <- fread("ec2cmpd.txt", data.table = F, header = F,col.names = c("EC","Cmpd","Type"))
cmpd.metabo_df <- fread("cmpd2metabo.txt", data.table = F, header = F,col.names = c("Cmpd","Metabo"))


ec.cmpd_df$Metabo <- 
  sapply(ec.cmpd_df$Cmpd,
         function(x){
           if(x %in% cmpd.metabo_df$Cmpd){
             tmp = cmpd.metabo_df$Metabo[which(cmpd.metabo_df$Cmpd == x)]
             if(length(tmp) == 1){
               m=tmp
             }else{
               m=tmp[startsWith(tmp, "C")]
             }
           }  else {m<-NA}
           
           return(m)
         })


write.table(ec.cmpd_df, sep = "\t", row.names = F, col.names = F, quote = F,
            file = "ec2metabo.txt")


