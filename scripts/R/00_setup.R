# required libraries
library(Seurat)
library(tidyverse)
library(patchwork)
library(spacexr)
library(ggrepel)
library(Matrix)
library(hdf5r)
library(arrow)
library(dplyr)
library(tidyr)

# needed to avoid error cluster_viz error in 04_STdeconvolve.R
options(ggrepel.max.overlaps = 20)  # increase default from 10

results_dir = "/Users/huyle/Desktop/Compbio_thesis/outputs"
sample_name = "ACA_211008"

spatial_folder <- file.path("/Users/huyle/Desktop/Compbio_thesis/10X_data", sample_name)
counts_file <- "Visium_FFPE_Human_Prostate_Acinar_Cell_Carcinoma_filtered_feature_bc_matrix.h5"