#!/usr/bin/Rscript

options(width=300)
args <-commandArgs (TRUE)

args = c("villinfh.pmat", "pdbs.pdbs")
matFile  =  args [1]
pdbsFile = args [2]

#pdbsTable = read.table (pdbsFile)
distMat   = as.dist (read.table (matFile, header=T))
