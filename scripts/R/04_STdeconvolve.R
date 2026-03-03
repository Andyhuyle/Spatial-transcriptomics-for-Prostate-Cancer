markers_raw <- read.csv("/Users/huyle/Desktop/Compbio_thesis/reference_markers.csv",
                        header = FALSE,
                        stringsAsFactors = FALSE)

markers_long <- markers_raw %>%
  rename(cell_type = V1) %>%
  pivot_longer(
    cols = -cell_type,
    names_to = "gene_col",
    values_to = "gene"
  ) %>%
  filter(!is.na(gene) & gene != "") %>%
  select(cell_type, gene)

markers_long <- markers_long %>%
  distinct(cell_type, gene)
markers_long <- split(markers_long$gene, markers_long$cell_type)

prostate_data <- AddModuleScore(
  object = prostate_data,
  features = markers_long,
  name = "CellTypeScore"
)

scores <- prostate_data@meta.data[, grep("CellTypeScore", colnames(prostate_data@meta.data))]

prostate_data$predicted_celltype <- colnames(scores)[max.col(scores)]
DimPlot(prostate_data, group.by="predicted_celltype", )
score_cols <- grep("CellTypeScore", colnames(prostate_data@meta.data), value = TRUE)

celltype_names <- names(markers_long)

prostate_data$predicted_celltype <- apply(
  prostate_data@meta.data[, score_cols],
  1,
  function(x) celltype_names[which.max(x)]
)

DimPlot(prostate_data, group.by="predicted_celltype", )

cluster_viz <- SpatialDimPlot(
  prostate_data,
  group.by = "predicted_celltype",
  label = TRUE,
  repel = TRUE,
  pt.size.factor = 1.5,
  label.size = 2,
  stroke = NA
) + guides(color = guide_legend(title = "Cell Type"))

ggsave(
  filename = file.path(results_dir, "plots", paste0(sample_name, "_cluster_viz_with_labels.png")),
  plot = cluster_viz,
  width = 10,
  height = 6
)

cluster_viz
