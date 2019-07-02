#!/usr/bin/Rscript

USAGE="\nCompute nmds scores using as input the distance matrix\
USAGE: nmds-analysis.R <distance matrix> => <nmds scores file>\n"

library (ecodist)
#library(vegan)
library (MASS)      # write.matrix: To write matrix to file 
options(width=300)
args <-commandArgs (TRUE)
#args = c("test33.dmat")

main <- function (){
	if (length (args) < 1) {
		cat (USAGE)
		quit()
	 }

	inDistanceMatrixFile = args [1]

	nmds_analysis (inDistanceMatrixFile)
}

#--------------------------------------------------------------
# Compute the nmds and write out the scores
#--------------------------------------------------------------
nmds_analysis <- function (inDistanceMatrixFile) {
	name                 = strsplit (inDistanceMatrixFile, split=".", fixed=T)[[1]][1]
	scoresFile           = paste (name, ".scores", sep="")

	ini = proc.time()
		cat ("\n>>> Reading matrix distance file: ", inDistanceMatrixFile, "\n")
		dmat   = as.dist (read.table (inDistanceMatrixFile, header=T))
	end = proc.time()
	cat ("\n>>>>>> Time reading distance matrix: ", end - ini, "\n")

	ini2 = proc.time()
		cat ("\n>>> Computing nmds...: \n")
		out    = nmds (dmat, mindim=2, maxdim=2)
	end2 = proc.time()
	cat ("\n>>>>>> Time computing nmds: ", end2 - ini2, "\n\n")

	scores = nmds.min (out)
	write.table (scores, file=scoresFile)
	end3 = proc.time()

	cat ("\n>>> Total time: reading, computing, writing: ", end3 - ini, "\n")
}

#if (grepl (".scores", inDistanceMatrixFile)) {
#	cat ("\n>>> Reading scores file: ", inDistanceMatrixFile, "\n")
#	scores = read.table (inDistanceMatrixFile)
#}

#print (scores)
#print (out$stress)

#pdf (file=pdfFile)
#  plot (scores, pch=20, col=topo.colors(nrow(scores)))
#dev.off()
#--------------------------------------------------------------
#--------------------------------------------------------------
main ()
