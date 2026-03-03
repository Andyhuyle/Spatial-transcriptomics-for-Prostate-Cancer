# pipeline adapted from https://satijalab.org/seurat/articles/spatial_vignette

# paths contained in 00_setup.R

# load raw rna counts
counts <- Read10X_h5(file.path(spatial_folder, counts_file))

# create spatial seurat object
prostate_data <- Load10X_Spatial(
  data.dir = spatial_folder,
  filename = counts_file,
  assay = "Spatial",
  filter.matrix = TRUE,
  to.upper = FALSE
)

# aligns barcodes between counts and spatial object
common_spots <- intersect(colnames(counts), colnames(prostate_data))
counts <- counts[, common_spots]
prostate_data <- subset(prostate_data, cells = common_spots)

# create rna assay and adds it
rna_assay <- CreateAssayObject(counts = counts)
prostate_data[["RNA"]] <- rna_assay

# QC filter: only keeps spots w/ counts more than 0
prostate_data <- subset(prostate_data, subset = nCount_Spatial > 0)
DefaultAssay(prostate_data) <- "RNA"
prostate_data <- NormalizeData(prostate_data)
prostate_data <- FindVariableFeatures(prostate_data)
prostate_data <- ScaleData(prostate_data)

# Expected: "Spatial" "RNA"
Assays(prostate_data)

# visualizes spatial counts
plot1 <- VlnPlot(prostate_data, features = "nCount_Spatial", pt.size = 0.1) 
ggsave(
  filename = file.path(results_dir, "plots", paste0(sample_name, "_nCount_Spatial_violin_plot.png")),
  plot = plot1,
  width = 10,
  height = 6
)

plot2 <- SpatialFeaturePlot(prostate_data, features = "nCount_Spatial",
                            pt.size.factor = 1.5) + theme(legend.position = "right")
ggsave(
  filename = file.path(results_dir, "plots", paste0(sample_name, "_nCount_Spatial_spatial_feature_plot.png")),
  plot = plot2,
  width = 10,
  height = 6
)

plot1 
plot2

