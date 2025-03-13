#multimodal reference mapping in seurat 
#tutorial

getwd()
setwd("/Users/zenadelmundo/Desktop/HW10")

library(Seurat)
library(ggplot2)
library(patchwork)
options(SeuratData.repo.use = "http://seurat.nygenome.org")

###load reference data####
reference <- readRDS("pbmc_multimodal_2023.rds")
DimPlot(object = reference, reduction = "wnn.umap", group.by = "celltype.l2", label = TRUE, label.size = 3, repel = TRUE) + NoLegend()
View(reference)

###load query data####
#load dataset to map#
library(SeuratData)
#InstallData('pbmc3k')
pbmc3k <- LoadData('pbmc3k')
pbmc3k <- UpdateSeuratObject(pbmc3k)
pbmc3k <- SCTransform(pbmc3k, verbose = FALSE) #normalize query
View(pbmc3k)

###mapping####
#find anchors between reference and query
anchors <- FindTransferAnchors(
  reference = reference,
  query = pbmc3k,
  normalization.method = "SCT",
  reference.reduction = "spca",
  dims = 1:50
) 
#transfer cell type labels and protein data from reference to query
#project query data onto UMAP structure of reference
pbmc3k <- MapQuery(
  anchorset = anchors,
  query = pbmc3k,
  reference = reference,
  refdata = list(
    celltype.l1 = "celltype.l1",
    celltype.l2 = "celltype.l2",
    predicted_ADT = "ADT"
  ),
  reference.reduction = "spca", 
  reduction.model = "wnn.umap"
)

####explore mapping results####
#umap 1#
p1 = DimPlot(pbmc3k, reduction = "ref.umap", group.by = "predicted.celltype.l1", label = TRUE, label.size = 3, repel = TRUE) + NoLegend()
#umap 2
p2 = DimPlot(pbmc3k, reduction = "ref.umap", group.by = "predicted.celltype.l2", label = TRUE, label.size = 3 ,repel = TRUE) + NoLegend()
p1 + p2

#featureplot 
DefaultAssay(pbmc3k) <- "prediction.score.celltype.l2"

FeaturePlot(pbmc3k, features = c("pDC", "Treg"),  
            reduction = "ref.umap", 
            cols = c("lightgrey", "darkred"), 
            ncol = 2) & 
  theme(plot.title = element_text(size = 10))

plot <- FeaturePlot(pbmc3k, features = "Treg",  
                    reduction = "ref.umap", 
                    cols = c("lightgrey", "darkred")) + 
  ggtitle("Treg") + 
  theme(plot.title = element_text(hjust = 0.5, size = 30)) + 
  labs(color = "Prediction Score") +  
  xlab("UMAP 1") + ylab("UMAP 2") +  
  theme(axis.title = element_text(size = 18), 
        legend.text = element_text(size = 18), 
        legend.title = element_text(size = 25))

ggsave(filename = "4_featureplot_Treg.jpg", 
       height = 7, width = 12, plot = plot, quality = 50)



#verify predictions by checking canonical marker genes
Idents(pbmc3k) <- 'predicted.celltype.l2'
#pDC - CLEC4C and LIRA4
VlnPlot(pbmc3k, features = c("CLEC4C", "LILRA4"), sort = TRUE) + NoLegend()
#treg - rtkn2, ctla4, foxp3
DefaultAssay(pbmc3k) <- 'predicted_ADT'
# see a list of proteins: rownames(pbmc3k)
FeaturePlot(pbmc3k, features = c("CD3-1", "CD45RA", "IgD"), reduction = "ref.umap", cols = c("lightgrey", "darkgreen"), ncol = 3)


#####De novo visualization####
#compute a new UMAP after merging referene and query to identify new populations (not present in reference, but present in query)
View(reference)

reference <- DietSeurat(reference, counts = FALSE, dimreducs = "spca")
pbmc3k <- DietSeurat(pbmc3k, counts = FALSE, dimreducs = "ref.spca")
#merge reference and query
reference$id <- 'reference'
pbmc3k$id <- 'query'
refquery <- merge(reference, pbmc3k)
refquery[["spca"]] <- merge(reference[["spca"]], pbmc3k[["ref.spca"]])
refquery <- RunUMAP(refquery, reduction = 'spca', dims = 1:50)
DimPlot(refquery, group.by = 'id', shuffle = TRUE)
