required_packages <- c(
  "tidyverse", "readxl", "openxlsx", "vegan",
  "indicspecies", "iNEXT", "adespatial", "igraph", "ggraph", "Hmisc",
  "permute"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages)) {
  stop(
    "Install the following packages before running the workflow: ",
    paste(missing_packages, collapse = ", ")
  )
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(openxlsx)
  library(vegan)
  library(indicspecies)
  library(iNEXT)
  library(adespatial)
  library(igraph)
  library(ggraph)
  library(Hmisc)
})

source("config/settings.R")
