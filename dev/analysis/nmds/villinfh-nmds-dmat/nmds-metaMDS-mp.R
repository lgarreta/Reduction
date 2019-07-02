#!/usr/bin/Rscript

library (vegan)
library (MASS)
library (parallel)

options(width=300)
args <-commandArgs (TRUE)

#m = metaMDSiter(dmat,engine="isoMDS", parallel = getOption("mc.cores"))
#m = metaMDSiter(dmat,engine="isoMDS", parallel = 4 )
#plot (m, col=heat.colors(429), type="p", pch=16,cex=2)

main <- function () {
	matFile = args [1]
	name = strsplit (matFile, "[.]")[[1]][1]
	nmdsFile = paste (basename(name), "-nmds.points", sep="")
	plotFile = paste (basename(name), "-nmds.pdf", sep="")

	msg ("Reading distance matrix file: ", matFile, "...")
	dmat = as.dist (read.table (matFile, header=T))

	msg ("Creating 3 replicas...")
	ini <- replicate(3, initMDS(dmat, 2))

	msg ("Solving parallel nmds...")
	sol <- mclapply(1:8, function(i) monoMDS(dmat, ini[,,i]), mc.cores=4)

	msg ("Obtaining best stress...")
	stresses <- sapply(sol, function(x) x$stress)
	best <- sol[[which.min(stresses)]]

	msg ("Writing points and plotting...")
	points <- best$points
	write.table (file=nmdsFile, points)

	pdf (file=plotFile)
		plot (points, col=heat.colors(429), type="p", pch=16,cex=2)
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
