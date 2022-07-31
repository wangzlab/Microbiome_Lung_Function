# input: 
# "metacyc.txt": metabolic reaction info derived from metacyc database
# "ec.txt": # ec list from last step

# output:
# "ec2cmpd.txt": # ec to metacyc compound mapping file




library(dplyr)
library(data.table)


reactions <- fread("metacyc.txt",data.table = F)
ecs <- fread("ec.txt", data.table = F, header = F, col.names = "EC")

ecs$EC <- gsub(":", "-", ecs$EC)


EC.Cmpd_df <- NULL
for(ec in ecs$EC){
  # ec=ecs$EC[1]
  
  tmp.rxn <- reactions %>% filter(`EC-NUMBER` == ec) %>% filter(`REACTION-DIRECTION` != "")
  if(nrow(tmp.rxn) == 0) next
  
  substrates <-strsplit(paste(c(tmp.rxn$LEFT[grep("LEFT-TO-RIGHT", tmp.rxn$`REACTION-DIRECTION`)],
                     tmp.rxn$RIGHT[grep("RIGHT-TO-LEFT", tmp.rxn$`REACTION-DIRECTION`)]),
                     collapse = ";") ,";",fixed = T)[[1]] %>% unique()
  
  products <- strsplit(paste(c(tmp.rxn$LEFT[grep("RIGHT-TO-LEFT", tmp.rxn$`REACTION-DIRECTION`)],
                               tmp.rxn$RIGHT[grep("LEFT-TO-RIGHT", tmp.rxn$`REACTION-DIRECTION`)]),
                             collapse = ";") ,";",fixed = T)[[1]] %>% unique()
  
  both1 <- intersect(substrates, products)
  
  revers.rxns <- tmp.rxn %>% filter(`REACTION-DIRECTION`=="REVERSIBLE")
  both2 <- strsplit(paste(c(revers.rxns$LEFT, revers.rxns$RIGHT),collapse = ";"),
                    ";", fixed = T)[[1]] %>% unique()
  
  Product_And_Substrate <- unique(c(both1,both2))
  
  substrates <- substrates[!substrates %in% Product_And_Substrate]
  products <- products[!products %in% Product_And_Substrate]
  
  
  ec.cpd_c <- 
    cbind.data.frame(
      EC = ec,
      Cmpd = c(substrates, products, Product_And_Substrate),
      Note = c(rep("Substrate",length(substrates)),
               rep("Product", length(products)),
               rep("Product_And_Substrate",length(Product_And_Substrate)))
    )
  
  
  EC.Cmpd_df<- bind_rows(EC.Cmpd_df, ec.cpd_c)
}


write.table(EC.Cmpd_df, file = "ec2cmpd.txt", sep = "\t", quote = F, row.names = F, col.names = F)
