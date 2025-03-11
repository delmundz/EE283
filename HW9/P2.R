###problem 2####
#4 to 6 panel figure from previous results - ATACseq

getwd()
setwd("/Users/zenadelmundo/Desktop/HW7")

## Problem 2 - 4-6 Pane figure from some previous results ####

load("../week7/deseq2_objs.Rdata")

# check dispersions and variance
pp1 = function(){ plotMA( res, ylim = c(-1, 1) ) }
pp2 = function(){ plotDispEsts( dds ) }


# Heatmap of sample distributions
rld = rlog( dds )
mydata = assay(rld)
sampleDists = dist( t( assay(rld) ) )
sampleDistMatrix = as.matrix( sampleDists )
rownames(sampleDistMatrix) = rld$TissueCode
colnames(sampleDistMatrix) = NULL
colours = colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pp3 = function(){ heatmap.2( sampleDistMatrix, trace="none", col=colours) }


# heatmap of top discriminating genes
topVarGenes <- head( order( rowVars( assay(rld) ), decreasing=TRUE ), 35 )
pp4 = function(){
  heatmap.2( assay(rld)[ topVarGenes, ], scale="row", trace="none", dendrogram="column", col = colorRampPalette( rev(brewer.pal(9, "RdBu")) )(255))
}


# Volcano plot
lfc = data.frame(res) %>%
  rownames_to_column(var = "gene.id") %>%
  filter(!is.na(log2FoldChange)) %>%
  mutate(sig.label = ifelse(padj <=0.001, gene.id, NA))

pp5 = ggplot(lfc, aes(log2FoldChange, -log10(padj))) +
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
                            max.overlaps = 50, alpha = 0.7 ) +
  theme_bw()

# plot
title = ggdraw() + draw_label("Dispersion and Variance in DEx Genes \n (Brain over Embryo)", fontface='bold')
z1 = plot_grid(pp1, pp2, labels=c("A","B"))
AB = plot_grid( title, z1, ncol=1, rel_heights = c(.1, 1))

title = ggdraw() + draw_label("Sample Clustering and Top Discriminating Genes", fontface='bold')
z2 = plot_grid(pp3, pp4, labels=c("C","D"))
CD = plot_grid( title, z2, ncol=1, rel_heights = c(.1, 1))

# expand the plot window a lot
row1 = plot_grid(AB, CD)
row2 = plot_grid(NULL, pp5, NULL, nrow = 1, labels =c("", "E", ""), rel_widths = c(.5,1,.5))
figure=plot_grid(row1, row2, ncol=1, rel_heights = c(1,1))
ggsave(plot = figure, "prob2_deseqresults.pdf",h=10, w=20)


library(ggplot2)
library(gridExtra)
library(cowplot)

# Load pre-generated plots (Modify paths as needed)
frag1 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/frag1.jpg")))
frag2 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/frag2.jpg")))
frag3 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/frag3.jpg")))
frag4 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/frag4.jpg")))

tss1 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/tss1.jpg")))
tss2 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/tss2.jpg")))
tss3 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/tss3.jpg")))
tss4 <- ggplot2::ggplot() + annotation_custom(rasterGrob(jpeg::readJPEG("/Users/zenadelmundo/Desktop/HW7/tss4.jpg")))

# Arrange plots in a 4- or 6-panel layout
title <- ggdraw() + draw_label("ATAC-seq Fragment Lengths & TSS Enrichment", fontface='bold')

row1 <- plot_grid(frag1, tss1, frag2, tss2, labels = c("A", "B", "C", "D"), ncol=2)
row2 <- plot_grid(frag3, tss3, frag4, tss4, labels = c("E", "F", "G", "H"), ncol=2)

# Adjust the figure size depending on panel count
figure <- plot_grid(title, row1, row2, ncol=1, rel_heights = c(0.1, 1, 1))

# Save the figure
ggsave(plot = figure, filename="/Users/zenadelmundo/Desktop/HW7/ATACseq_figure.pdf", height=10, width=15)



## Problem 3 - Make Two Manhattan Plots ####

# mod1
res1 = read.csv("../week8/interaction of treatment to founder at each genome position by two models (neg.log10p).csv") %>%
  mutate(
    SNP = paste0(chr,"_",pos),
    CHR = chr,
    BP = pos,
    P = mod1.signif # notice model 1
  ) %>%
  select(CHR, BP, SNP, P)

chrs = res1 %>%
  distinct(CHR) %>%
  mutate(
    CHR_num = case_when(
      CHR =="chrX" ~ 1,
      CHR =="chr2L" ~ 2,
      CHR =="chr2R" ~ 3,
      CHR =="chr3L" ~ 4,
      CHR =="chr3R" ~ 5
    )
  )

res1_num = res1 %>%
  left_join(.,chrs) %>%
  select(-CHR) %>%
  rename(
    CHR = "CHR_num"
  )


p1 = function(){
  manhattan(res1_num, main = "Significant SNPs from Model1",
            ylim = c(0, 10), cex = 0.6, cex.axis = 0.9,
            col = c("blue4", "orange3"),
            suggestiveline = -log10(1e-05),
            genomewideline = -log10(5e-08),
            logp=TRUE,
            chrlabs = chrs$CHR)
}


# mod 2
res2 = read.csv("../week8/interaction of treatment to founder at each genome position by two models (neg.log10p).csv") %>%
  mutate(
    SNP = paste0(chr,"_",pos),
    CHR = chr,
    BP = pos,
    P = mod2.signif # notice model 2
  ) %>%
  select(CHR, BP, SNP, P)

chrs = res2 %>%
  distinct(CHR) %>%
  mutate(
    CHR_num = case_when(
      CHR =="chrX" ~ 1,
      CHR =="chr2L" ~ 2,
      CHR =="chr2R" ~ 3,
      CHR =="chr3L" ~ 4,
      CHR =="chr3R" ~ 5
    )
  )

res2_num = res2 %>%
  left_join(.,chrs) %>%
  select(-CHR) %>%
  rename(
    CHR = "CHR_num"
  )


p2 = function(){
  manhattan(res2_num, main = "Significant SNPs from Model 2",
            ylim = c(0, 10), cex = 0.6, cex.axis = 0.9,
            col = c("blue4", "orange3"),
            suggestiveline = -log10(1e-05),
            genomewideline = -log10(5e-08),
            logp=TRUE,
            chrlabs = chrs$CHR)
}

z = plot_grid(p1, p2, ncol = 1)
print(z)
ggsave("prob3_manhattan plots.pdf",h=9,w=8)

## Problem 4 - Make Manhattan with myManhattan package ####
source("mymanhattan.R")

gg1 = myManhattan(res1_num, chrom.lab =chrs$CHR, graph.title = "Significant SNPs from Model 1")
gg2 = myManhattan(res2_num, chrom.lab =chrs$CHR, graph.title = "Significant SNPs from Model 2")

plot_grid(gg1, gg2, ncol =1)
ggsave("prob4_manhattan from myManhattan.pdf", width=8, height=9)

## Problem 5 - add third pane with comparison of model pvalues ####

merge = read.csv("../week8/interaction of treatment to founder at each genome position by two models (neg.log10p).csv") %>%
  mutate(
    SNP = paste0(chr,"_",pos),
    CHR = chr,
    BP = pos,
    label = ifelse( abs( log10(mod1.signif)-log10(mod2.signif)/mod1.signif)*100 > 50 , SNP,NA)
  )


SNP = ggplot(merge, aes( mod1.signif , mod2.signif) ) +
  labs(
    title = "Comparison of SNP Model Results",
    subtitle = "SNPs with > 50% difference in -log10pval are labeled red",
    x= "-log10 of pvalues from Model 1 ",   y= "-log10 of pvalues from Model 2 "
  ) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(size = .2, alpha = .4, color = "black") +
  geom_point(size = .2,
             data = subset(merge, is.na(label) == FALSE),
             color = "red"
  ) +
  ggrepel::geom_text_repel( aes( label = label ),
                            vjust = 1.0,
                            box.padding = 0.5,
                            size = 2.0,
                            max.overlaps = 100, alpha = 0.7 ) +
  theme_bw()



MP = plot_grid(gg1, gg2, ncol =1)
plot_grid(MP, SNP, nrow=1, rel_widths = c(1.7, 1))
ggsave("prob5_finalfigure.pdf", h=6, w=12)


myManhattan <- function(df, graph.title = "", highlight = NULL, highlight.col = "green",
                        col = c("lightblue", "navy"), even.facet = FALSE, chrom.lab = NULL,
                        suggestiveline = 1e-05, suggestivecolor = "blue",
                        genomewideline = 5e-08, genomewidecolor = "red",
                        font.size = 12, axis.size = 0.5, significance = NULL, report = FALSE,
                        inf.corr = 0.95, y.step = 2, point.size = 1){
  myMin <- min(df$P[df$P != 0]) * inf.corr
  df$P[df$P == 0] <- myMin
  require(ggplot2)
  require(stats)
  y.title <- expression(-log[10](italic(p)))
  if (length(col) > length(unique(df$CHR))){
    chrom.col <- col[1:length(unique(df$CHR))]
  } else if (!(length(col) > length(unique(df$CHR)))){
    chrom.col <- rep(col, length(unique(df$CHR))/length(col))
    if (length(chrom.col) < length(unique(df$CHR))){
      dif <- length(unique(df$CHR)) - length(chrom.col)
      chrom.col <- c(chrom.col, col[1:dif])
    }
  }
  y.max <- floor(max(-log10(df$P))) + 1
  if (y.max %% 2 != 0){
    y.max <- y.max + 1
  }
  if (!is.null(chrom.lab)){
    if (length(unique(df$CHR)) != length(chrom.lab)){
      warning("Number of chrom.lab different of number of chromosomes in dataset, argument ignored.")
    } else {
      df$CHR <- factor(df$CHR, levels = unique(df$CHR), labels=chrom.lab)
    }
  }
  g <- ggplot(df) +
    geom_point(aes(BP, -log10(P), colour = as.factor(CHR)), size = point.size)
  if (!is.null(significance)){
    if (is.numeric(significance)){
      genomewideline <- significance
      suggestiveline <- genomewideline / 0.005
    } else if (significance == "Bonferroni"){
      BFlevel <- 0.05 / length(df$SNP)
      cat("Bonferroni correction significance level:", BFlevel, "\n")
      genomewideline <- BFlevel
      suggestiveline <- BFlevel / 0.005
    } else if (significance == "FDR"){
      df$fdr <- p.adjust(df$P, "fdr")
      genomewideline <- 0.05
      suggestiveline <- FALSE
      y.title <- expression(-log[10](italic(q)))
      g <- ggplot(df) +
        geom_point(aes(BP, -log10(fdr), colour = as.factor(CHR)), size = point.size)
      if (!is.null(highlight)) {
        if (is.numeric(highlight)){
          highlight <- as.character(df$SNP[df$P < highlight])
        }
        if (any(!(highlight %in% df$SNP))){
          warning("Cannot highlight SNPs not present in the dataset. Argument is ignored.")
        } else {
          g <- g + geom_point(data = df[which(df$SNP %in% highlight), ],
                              aes(BP, -log10(fdr), group=SNP, colour=SNP),
                              color = highlight.col, size = point.size)
          highlight <- NULL
          y.max <- floor(max(-log10(df$fdr))) + 1
          if (y.max %% 2 != 0){
            y.max <- y.max + 1
          }
        }
      }
    }
  }
  if (even.facet){
    g <- g + facet_grid(.~CHR, scale = "free_x", switch = "x")
  } else {
    g <- g + facet_grid(.~CHR, scale = "free_x", space = "free_x", switch = "x")
  }
  g <- g + scale_colour_manual(values = chrom.col) +
    scale_y_continuous(expand = c(0, 0), limit = c(0, y.max),
                       breaks = seq(from = 0, to = y.max, by = y.step)) +
    scale_x_continuous() +
    theme(strip.background = element_blank(), legend.position = "none",
          axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.spacing.x=unit(0.1, "lines"),
          axis.line.y = element_line(size = axis.size, color = "black"),
          axis.ticks.y = element_line(size = axis.size, color = "black"),
          axis.ticks.length = unit(axis.size * 10, "points"),
          plot.title = element_text(hjust = (0.5), size = font.size + 8),
          axis.title.y = element_text(size = font.size + 5),
          axis.title.x = element_text(size = font.size + 5),
          axis.text = element_text(size = font.size),
          strip.text.x = element_text(size = font.size))+
    labs(title = graph.title, x = "Chromosome", y = y.title)
  if (!is.null(highlight)) {
    if (is.numeric(highlight)){
      highlight <- as.character(df$SNP[df$P < highlight])
    }
    if (any(!(highlight %in% df$SNP))){
      warning("Cannot highlight SNPs not present in the dataset. Argument is ignored.")
    } else {
      g <- g + geom_point(data = df[which(df$SNP %in% highlight), ],
                          aes(BP, -log10(P), group=SNP, colour=SNP),
                          color = highlight.col, size = point.size)
    }
  }
  if (suggestiveline){
    g <- g + geom_hline(yintercept = -log10(suggestiveline), color = suggestivecolor)
  }
  if (genomewideline){
    g <- g + geom_hline(yintercept = -log10(genomewideline), color = genomewidecolor)
  }
  if (report){
    if (significance == "FDR"){
      rep <- df[df$fdr < 0.05, ]
    } else if (significance == "Bonferroni"){
      rep <- df[df$P < BFlevel, ]
    } else if (is.numeric(significance)){
      rep <- df[df$P < significance, ]
    } else {
      cat("using default significance level, 5e-8")
      rep <- df[df$P < 5e-8, ]
    }
    print(rep)
  }
  return(g)
}