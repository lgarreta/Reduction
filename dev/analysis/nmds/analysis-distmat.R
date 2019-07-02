#!/usr/bin/Rscript

USAGE="\nCompute nmds scores using as input the distance matrix\
USAGE: nmds-analysis.R <distance matrix> => <nmds scores file>\n"

options(width=300)
args <-commandArgs (TRUE)

library (factoextra)
#args = c("test33.dmat")

main <- function (){
	if (length (args) < 1) {
		cat (USAGE)
		quit()
	 }

	inDistanceMatrixFile = args [1]

	distmat_analysis (inDistanceMatrixFile)
}

#--------------------------------------------------------------
# Compute the nmds and write out the scores
#--------------------------------------------------------------
distmat_analysis <- function (inDistanceMatrixFile) {
	name      = strsplit (inDistanceMatrixFile, split=".", fixed=T)[[1]][1]
	pdfFile   = paste (name, ".pdf", sep="")

	distMat = as.dist (read.table (inDistanceMatrixFile, header=T))

	fviz_dist(distMat)
	#gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
	#gradient = list(low = "blue",  mid = "yellow", high = "red"))
}

#--------------------------------------------------------------
#--------------------------------------------------------------
main ()
