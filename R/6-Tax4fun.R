#!/usr/bin/env Rscript

library(Tax4Fun)
source("https://bioconductor.org/biocLite.R")
biocLite("rhdf5")

files = c("useful/closed/feature-table-tax4fun.txt")

QIIMEData = importQIIMEData(files)
# Point to the SILVA123 precomputed files
pathReferenceData = "classifiers/tax4fun/SILVA123"

Tax4FunOutput <- Tax4Fun(QIIMEData,pathReferenceData, fctProfiling = FALSE, refProfile = "UProC", shortReadMode = TRUE, normCopyNo = TRUE)

Tax4FunProfile <- data.frame(t(Tax4FunOutput$Tax4FunProfile))

write.table(Tax4FunProfile,"useful/tax4fun/Tax4FunProfile_Export.csv",sep="\t")