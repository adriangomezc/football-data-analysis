required_packages <- c(
  "tidyverse",
  "data.table",
  "ggplot2",
  "ggrepel",
  "cluster",
  "factoextra",
  "plotly",
  "scales",
  "cowplot",
  "patchwork",
  "corrplot",
  "dbscan",
  "proxy",
  "caret",
  "randomForest",
  "xgboost",
  "coop",
  "dplyr"
)

installed <- rownames(installed.packages())

for(pkg in required_packages){
  
  if(!(pkg %in% installed)){
    install.packages(pkg)
  }
  
  library(pkg, character.only = TRUE)
}

cat("All packages loaded successfully.\n")
