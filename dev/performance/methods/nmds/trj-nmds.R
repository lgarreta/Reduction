#!/usr/bin/Rscript

USAGE="Compute (or plot) the nMDS of a distance matrix (or points).\n
USAGE: ndms-monoMDS.R <distance matrix | points >\n"

options(width=300)
args <-commandArgs (TRUE)
#args = c("2RN2CA.pmat")
#args = c("villinfh-nmds.points")
if (length(args) < 1) {
	cat (USAGE)
	quit()
}

library (vegan)
library (MASS)
library (parallel)
library (calibrate) # textxy: for labels to points

source ("pmat_distance_matrix.R")

main <- function () {
	pdbsDir = args [1]  # matrix (.pmat) or points (.points)
	nCores = as.numeric (args [2])  
	name = strsplit (pdbsDir, "[.]")[[1]][1]

	distMat = calcPmat (pdbsDir, nCores, name)

	msg ("Initiating MDS...")
	ini <- initMDS(distMat, 2)

	msg ("Solving parallel nmds...")
	outMds <- monoMDS(distMat, ini)

	msg ("Writing points... ")
	nmdsFile = paste (basename(name), "-nmds.points", sep="")
	pointsData <- outMds$points
	renameOldFile (nmdsFile)
	write.table (file=nmdsFile, pointsData)
}


#----------------------------------------------------------
# Rename old file if it exists (old-xxxxxx)
#----------------------------------------------------------
renameOldFile <- function (newFile) {
	checkOldFile <- function (newFile) {
		name  = basename (newFile)
		path  = dirname  (newFile)
		if (file.exists (newFile) == T) {
			oldFile = sprintf ("%s/old-%s", path, name)
			if (file.exists (oldFile) == T) {
				checkOldFile (oldFile)
			}

			file.rename (newFile, oldFile)
		}
	}
	checkOldFile (newFile)
}

#-------------------------------------------------------------
# Print a log message with the parameter
#-------------------------------------------------------------
msg <- function (...) {
	messages = unlist (list (...))
	cat (">>>>", messages, "\n")
}
#-------------------------------------------------------------
#-------------------------------------------------------------
main ()
