# scripts/setup_packages.R

packages <- c(
  "tidyverse",
  "ggrepel",
  "viridis",
  "cluster",
  "factoextra",
  "fmsb"
)

installed <- packages %in% installed.packages()

if(any(!installed)) {
  install.packages(packages[!installed])
}

invisible(lapply(packages, library, character.only = TRUE))
