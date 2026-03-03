# Sketch
DefaultAssay(prostate_data) <- "sketch"

# dimensional reduction
prostate_data <- FindVariableFeatures(prostate_data)
prostate_data <- ScaleData(prostate_data)
prostate_data <- RunPCA(prostate_data, assay = "sketch", reduction.name = "pca.sketch")

# cluster
prostate_data <- FindNeighbors(prostate_data, assay = "sketch",
                               reduction = "pca.sketch", dims = 1:50)
prostate_data <- FindClusters(prostate_data, cluster.name = "seurat_cluster.sketched",
                              resolution = 3)
prostate_data <- RunUMAP(prostate_data, reduction = "pca.sketch",
                         reduction.name = "umap.sketch", return.model = T, dims = 1:50)

# project clustering onto complete data
prostate_data <- ProjectData(object = prostate_data, assay = "Spatial",
                             full.reduction = "full.pca.sketch", sketched.assay = "sketch",
                             sketched.reduction = "pca.sketch", umap.model = "umap.sketch",
                             dims = 1:50, refdata = list(seurat_cluster.projected = "seurat_cluster.sketched"))

# visualize clusters
DefaultAssay(prostate_data) <- "sketch"
Idents(prostate_data) <- "seurat_cluster.sketched"
p1 <- DimPlot(prostate_data, reduction = "umap.sketch", label = F) +
  ggtitle("Sketched clustering (50,000 cells)") + theme(legend.position = "bottom")
ggsave(
  filename = file.path(results_dir, "plots", paste0(sample_name, "_sketched_clustering_50k.png")),
  plot = p1,
  width = 10,
  height = 6
)
p1

DefaultAssay(prostate_data) <- "Spatial"
Idents(prostate_data) <- factor(prostate_data$seurat_cluster.projected,
                                levels = sort(as.numeric(as.character(unique(prostate_data$seurat_cluster.projected)))))
p2 <- DimPlot(prostate_data, reduction = "full.umap.sketch",
              label = F) + ggtitle("Projected clustering") + theme(legend.position = "right")
ggsave(
  filename = file.path(results_dir, "plots", paste0(sample_name, "_projected_clustering.png")),
  plot = p2,
  width = 10,
  height = 6
)

p2

cluster_viz <- SpatialDimPlot(prostate_data, label = T, repel = T,
                              pt.size.factor = 1.5, label.size = 2, stroke = NA) + guides(color = guide_legend(title = "Clusters")) 
ggsave(
  filename = file.path(results_dir, "plots", paste0(sample_name, "_cluster_viz_no_labels.png")),
  plot = cluster_viz,
  width = 10,
  height = 6
)

cluster_viz

# SECOND SAVE CHECKPOINT
saveRDS(object = prostate_data, 
        file = file.path(results_dir, "checkpoints", paste0(sample_name, "_clusters.rds")))