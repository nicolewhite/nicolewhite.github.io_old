#!/usr/bin/env Rscript
args = commandArgs(TRUE)

setwd('../_drafts')
library(knitr)

if(args[1] == "publish") {
  dir = paste0("../_posts/", Sys.Date(), "-")
} else if(args[1] == "preview") {
  dir = "../_drafts/"
} else {
  stop("You must publish or preview a .Rmd file.")
}

file = args[2]

if(!grepl(".Rmd", file)) {
  stop("You must specify a .Rmd file.")
}

output = paste0(dir, sub('.Rmd', '.md', file))
knit(file, output)
