# normalize, find variable features, and scale data
prostate_data <- NormalizeData(prostate_data, assay = "Spatial")
prostate_data <- FindVariableFeatures(prostate_data)
prostate_data <- ScaleData(prostate_data)

prostate_data <- SketchData(object = prostate_data, ncells = 50000,
                            method = "LeverageScore", sketched.assay = "sketch")

# FIRST SAVE CHECKPOINT
saveRDS(object = prostate_data, 
        file = file.path(results_dir, "checkpoints", paste0(sample_name, "_processed_50k.rds")))

