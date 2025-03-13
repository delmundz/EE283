#load library
library(tidyverse)

#current working dir
getwd()
#dataframe with RNAseq info
mytab = read_tsv("RNAseq384_SampleCoding.txt")
#check mytab
mytab

#create new dataframe with select columns from original
mytab2 <- mytab %>%
  select(RILcode, TissueCode, Replicate, FullSampleName)	
table(mytab2$RILcode)
table(mytab2$TissueCode)
table(mytab2$Replicate)

mytab2 <- mytab %>%
  select(RILcode, TissueCode, Replicate, FullSampleName) %>%
  filter(RILcode %in% c(21148, 21286, 22162, 21297, 21029, 22052, 22031, 21293, 22378, 22390)) %>%
  filter(TissueCode %in% c("B", "E")) %>%
  filter(Replicate == "0")

#for each row of mytab2, writes a line to "shortRNAseq.names.txt"
for(i in 1:nrow(mytab2)){
  cat("/pub/delmundz/Work_ee283/HW2/alignRNAseq/aligned",mytab2$FullSampleName[i],".sort.bam\n",file="shortRNAseq.names.txt",append=TRUE,sep='')
}
write_tsv(mytab2,"shortRNAseq.txt")
