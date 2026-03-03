# Base output directory
base_dir <- file.path(results_dir, "FeaturePlots_by_CellType")
dir.create(base_dir, showWarnings = FALSE, recursive = TRUE)

# Loop over each cell type
for (ct in names(markers_long)) {
  
  cat("Processing:", ct, "\n")
  
  genes <- markers_long[[ct]]
  
  # Keep only genes present in dataset
  genes_present <- genes[genes %in% rownames(prostate_data)]
  
  if (length(genes_present) == 0) {
    cat("No valid genes found for", ct, "\n")
    next
  }
  
  # Make folder (sanitize name for filesystem)
  ct_clean <- gsub("[^A-Za-z0-9_]", "_", ct)
  ct_dir <- file.path(base_dir, ct_clean)
  dir.create(ct_dir, showWarnings = FALSE)
  
  # ---- OPTION A: One multi-panel plot per cell type ----
  p <- FeaturePlot(
    prostate_data,
    features = genes_present,
    min.cutoff = "q05",
    max.cutoff = "q95",
    ncol = 3
  )
  
  ggsave(
    filename = file.path(ct_dir, paste0(ct_clean, "_FeaturePlot.png")),
    plot = p,
    width = 12,
    height = 8
  )
  
}

library(magick)

# ---- 1. Define folder ----
image_dir <- file.path(results_dir, "FeaturePlots_by_CellType")

images <- list.files(
  image_dir,
  pattern = "\\.png$",
  recursive = TRUE,
  full.names = TRUE
)

cat("Found", length(images), "PNG files\n")

# ---- 2. Read images ----
img_list <- lapply(images, function(x) {
  tryCatch(image_read(x), error = function(e) NULL)
})

img_list <- img_list[!sapply(img_list, is.null)]

if (length(img_list) == 0) {
  stop("No valid images found.")
}

# ---- 3. Normalize size (important for clean rectangle) ----
img_list <- lapply(img_list, function(img) {
  image_resize(img, "1200x900!")
})

# ---- 4. Compute rectangular layout automatically ----
n_images <- length(img_list)

ncol <- ceiling(sqrt(n_images))
nrow <- ceiling(n_images / ncol)

cat("Grid layout:", nrow, "rows x", ncol, "columns\n")

# ---- 5. Build grid ----
row_images <- list()

for (r in 1:nrow) {
  
  start_idx <- (r - 1) * ncol + 1
  end_idx   <- min(r * ncol, n_images)
  
  row_imgs <- img_list[start_idx:end_idx]
  
  row_images[[r]] <- image_append(do.call(c, row_imgs))
}

grid_image <- image_append(do.call(c, row_images), stack = TRUE)

# ---- 6. Save ----
output_path <- file.path(results_dir, "All_FeaturePlots_Rectangle.png")
image_write(grid_image, output_path)

cat("Saved rectangular grid to:", output_path, "\n")