#!/usr/bin/env Rscript
setwd('../_drafts')
library(knitr)

args = commandArgs(TRUE)
file = args[1]

if(!grepl(".Rmd", file)) {
  stop("You must specify a .Rmd file.")
}

dir = paste0("../_posts/", Sys.Date(), "-")
output = paste0(dir, sub('.Rmd', '.md', file))
knit(file, output)
