#!/usr/bin/Rscript

USAGE="Compute (or plot) the nMDS of a distance matrix (or points).\n
USAGE: ndms-monoMDS.R <distance matrix | points >\n"

options(width=300)
args <-commandArgs (TRUE)
#args = c("2RN2CA.pmat")
args = c("villinfg-nmds.points")
if (length(args) < 1) {
	cat (USAGE)
	quit()
}

library (vegan)
library (MASS)
library (parallel)


#m = metaMDSiter(dmat,engine="isoMDS", parallel = getOption("mc.cores"))
#m = metaMDSiter(dmat,engine="isoMDS", parallel = 4 )
#plot (m, col=heat.colors(429), type="p", pch=16,cex=2)

main <- function () {
	inFile = args [1]  # matrix (.pmat) or points (.points)
	name = strsplit (inFile, "[.]")[[1]][1]
	ext  = strsplit (inFile, "[.]")[[1]][2]

	plotFile = paste (basename(name), "-nmds.pdf", sep="")

	if (ext == "pmat") {
		matFile = inFile
		nmdsFile = paste (basename(name), "-nmds.points", sep="")

		msg ("Reading distance matrix file: ", matFile, "...")
		dmat = as.dist (read.table (matFile, header=T))

		msg ("Initiating MDS...")
		ini <- initMDS(dmat, 2)

		msg ("Solving parallel nmds...")
		outMds <- monoMDS(dmat, ini)

		msg ("Writing points... ")
		points <- outMds$points
		renameOldFile (nmdsFile)
		write.table (file=nmdsFile, points)

	}else if (ext == "points") {
		msg ("Loading points...", inFile)
		points = read.table (inFile, header=T)
	}

	msg ("Ploting...", plotFile)
	renameOldFile (plotFile)
	n = nrow (points)
	pdf (file=plotFile)
		plot (points, col=topo.colors(n), type="p", pch=16,cex=0.8)
	dev.off()


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
