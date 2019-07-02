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
		pointsData <- outMds$points
		renameOldFile (nmdsFile)
		write.table (file=nmdsFile, pointsData)

	}else if (ext == "points") {
		msg ("Loading points...", inFile)
		pointsData <<- read.table (inFile, header=T)
	}else if (ext == "scores") {
		scoresFile = inFile
		nmdsFile = paste (basename(name), "-nmds.points", sep="")
		msg ("Reading scores file: ", scoresFile, "...")
	}

	msg ("Ploting...", plotFile)
	renameOldFile (plotFile)
	n = nrow (pointsData)
	pdf (file=plotFile, width=10)
		colors <- rainbow (n, start=0.2)	
		npoints = seq (1,n,20)

		xcolors = colors [npoints]
		x = pointsData [npoints,1]
		y = pointsData [npoints,2]

		layout(matrix(1:2,ncol=2), width = c(2,1),height = c(1,1))
		plot (x,y, col=xcolors, type="p", pch=16,cex=1.0)
		textxy (x,y, labs=npoints, cex=1)
		#plot(1:20, 1:20, pch = 19, cex=2, col = colfunc(20))

		legend_image <- as.raster(matrix(colors, ncol=1))
		plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', main = 'rainbow (0.2)', cex.main=1.5)
		text(x=1, y = seq(0,1,l=5), labels = seq(0,1,l=5))
		rasterImage(legend_image, -1, 0, 0.5,1)

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
