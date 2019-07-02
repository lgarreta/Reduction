#!/usr/bin/Rscript

USAGE="Compute (or plot) the nMDS of a distance matrix (or points).\n
USAGE: plot-analysis.R < scores PDBs File > < points nmds file > => two plots\n"

options(width=300)
args <-commandArgs (TRUE)
#args = c("2RN2CA.pmat")
#args = c("villinfh-nmds.points")
#args = c("analysis-trajectory-2RN2CA-pdbsGlobal.scores", "analysis-nmds-2RN2CA-nmds.points")
if (length(args) < 2) {
	cat (USAGE)
	quit()
}

main <- function () {
	scoresPDBsFile = args [1]  # matrix (.pmat) or points (.points)
	pointsFile = args [2]

	plotNMDS (pointsFile)
	plotTrajectory (scoresPDBsFile)
}

#----------------------------------------------------------
# Create the nMDS plot from nmds points file
#----------------------------------------------------------
plotNMDS <- function (pointsFile, colors) {
	name = strsplit (pointsFile, "[.]")[[1]][1]
	plotFile = paste (basename(name), "-palette.pdf", sep="")

	msg ("Loading points...", pointsFile)
	pointsData <- read.table (pointsFile, header=T)
	n = nrow (pointsData)
	xcolors <- rainbow (n, start=0.2)	

	msg ("Plotting nMDS with palette...")
	pdf (file=plotFile, width=5, height=5)
		npoints = seq (1,n,1)
		x = pointsData [npoints,1]
		y = pointsData [npoints,2]

		#layout(matrix(1:2,ncol=2), width = c(1.5,0.5),height = c(1,1))
		par(mar = c(4,4,2,0)+0.1)
		plot (x,y, col=xcolors, type="p", pch=16, cex=0.5,
			 cex.axis=1.5,cex.lab=2.0)
		#textxy (x,y, labs=npoints, cex=1)

		#legend_image <- as.raster(as.matrix(xcolors, ncol=1))
		#par(mar = c(3,1,1,4))
		#plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', 
		#	 main = 'rainbow (0.2)', cex.main=1.5)
		#text(x=1, y = seq(0,1,l=5), labels = seq(0,1,l=5))
		#rasterImage(legend_image, -1, 0, 0.5,1)
	dev.off()
}

#----------------------------------------------------------
# Rename old file if it exists (old-xxxxxx)
#----------------------------------------------------------
plotTrajectory <- function (scoresPDBsFile, xcolors) {
	name = strsplit (scoresPDBsFile, "[.]")[[1]][1]
	plotFile = paste (basename(name), "-palette.pdf", sep="")

	msg ("Reading scores file: ", scoresPDBsFile, "...")
	scoresData = read.table (scoresPDBsFile, header=F)
	n = nrow (scoresData)
	x = seq (n)
	y = scoresData [,2]
	xcolors <- rainbow (n, start=0.2)	

	msg ("Plotting trajectory with palette...")
	pdf (file=plotFile, width=10, height=4)
		layout(matrix(1:2,ncol=1), widths = c(2,2),heights = c(2.5,0.5))
		par (mar=c(4,4.2,2.5,0)+0.1)
		plot (x,y, type="l", pch=16,cex=0.8, xlab="Time steps", ylab="TM-scores", bty="l",
			 cex.axis=1.5,cex.lab=2.0)

		legend_image <- as.raster(matrix(xcolors, nrow=1))
		par(mar = c(0,3,1,0))
		plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', cex.main=1.5)
		rasterImage(legend_image, 0, 0, 2,1)
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
