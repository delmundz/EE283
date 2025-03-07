#current working dir
getwd()
setwd("/Users/zenadelmundo/Desktop/HW7")

###deseq P2
# differential expression analysis to compare brain vs. embryo

library(tidyverse)
library(DESeq2)
library(cowplot)

getwd()

sampleInfo = read.delim("shortRNAseq.txt")
sampleInfo$FullSampleName = as.character(sampleInfo$FullSampleName)
countdata = read.table("fly_counts.txt", header=TRUE, row.names=1)
View(sampleInfo)
View(countdata)

# Remove unnecessary columns - first five columns (chr, start, end, strand, length)
countdata = countdata[ ,6:ncol(countdata)]
# Remove crap from colnames in countdata
temp = colnames(countdata)
View(temp)
temp = gsub("X.pub.delmundz.Work_ee283.HW3.alignRNAseq.aligned.","",temp)
temp = gsub(".sort.bam","",temp)
colnames(countdata) = temp

# check if cleaned column names match the fullsamplename in sampleinfo
cbind(temp,sampleInfo$FullSampleName,temp == sampleInfo$FullSampleName)

# create DEseq2 object
dds = DESeqDataSetFromMatrix(countData=countdata, colData=sampleInfo, design=~TissueCode)
#run deqseq
dds <- DESeq(dds)
#extract results, compare brain to embryo tissues
res <- results( dds, contrast = c("TissueCode","B","E") )
#prints summart of differential expression
summary(res)

# create diagnostic plots: an MA plot, dispersion estimates plot, and a histogram of p-values
plotMA( res, ylim = c(-1, 1) )
plotDispEsts( dds )
hist( res$pvalue, breaks=20, col="grey" )

#apply log transform to count data
rld = rlog( dds )
View(rld)
## display 1st few rows of transformed data and assigns to mydata
head( assay(rld) )
mydata = assay(rld)

#calculate distance between samples based on transformed data
sampleDists = dist( t( assay(rld) ) )

#convert distances to matrix and set rownames to tissue codes
sampleDistMatrix = as.matrix( sampleDists )
rownames(sampleDistMatrix) = rld$TissueCode
colnames(sampleDistMatrix) = NULL

#create heatmap of sample distances
library( "gplots" )
library( "RColorBrewer" )
colours = colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
heatmap.2( sampleDistMatrix, trace="none", col=colours)

# PCA plot, colored by tissue code
print( plotPCA( rld, intgroup = "TissueCode") )

# heat map - top 35 most variable genes
library( "genefilter" )
# these are the top genes (that tell tissue apart no doubt)
topVarGenes <- head( order( rowVars( assay(rld) ), decreasing=TRUE ), 35 )
library(pheatmap)
pheatmap(assay(rld)[topVarGenes, ], scale="row", 
         color = colorRampPalette(rev(brewer.pal(9, "RdBu")))(255),
         cellwidth = 10, cellheight = 10)

####volcano plot###
#prep data - add gene ids as a column, create label for significant genes
lfc = data.frame(res) %>%
  rownames_to_column(var = "gene.id") %>%
  filter(!is.na(log2FoldChange)) %>%
  mutate(sig.label = ifelse(padj <=0.01, gene.id, NA))
#creates volcano plot - log2foldchange vs. log10(adjusted p-value)
ggplot(lfc, aes(log2FoldChange, -log10(padj))) +
  geom_hline(yintercept = -log10(0.01), linetype = "dashed", color = "red") +
  geom_vline(xintercept = 1, linetype = "dotted", color = "black", alpha = .5) +
  geom_vline(xintercept = -1, linetype = "dotted", color = "black", alpha = .5) +
  geom_point(size = .2, alpha = .4, color = "grey80") +
  geom_point(size = .2,
             data = subset(lfc, is.na(sig.label) == FALSE),
             color = "black"
  ) +
  labs( x="Log2FC(Brain/Embryo)", title = "Fly Brain vs Embryo Deseq2") +
  
  ggrepel::geom_text_repel( aes( label = sig.label ),
                            vjust = 1.0,
                            box.padding = 0.5,
                            size = 2.0,
                            max.overlaps = 100, alpha = 0.7 ) +
  theme_bw()

dev.off()
ggsave("DEx Brain vs Embryo deseq2.pdf",h=8,w=10)
