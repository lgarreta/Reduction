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


	msg ("Reading scores file: ", scoresPDBsFile, "...")
	scoresData = read.table (scoresPDBsFile, header=F)
	n = nrow (scoresData)
	xValues = round (seq(1,n,l=5), 0)
	xColors <- rainbow (n, start=0.2)	

	plotNMDS (pointsFile, xColors, n, xValues)
	plotTrajectory (scoresPDBsFile, xColors, xValues)
}

#----------------------------------------------------------
# Create the nMDS plot from nmds points file
#----------------------------------------------------------
plotNMDS <- function (pointsFile, xColors, n, xValues) {
	name = strsplit (pointsFile, "[.]")[[1]][1]
	plotFile = paste (basename(name), "-palette.pdf", sep="")

	msg ("Loading points...", pointsFile)
	pointsData <- read.table (pointsFile, header=T)
	n = nrow (pointsData)

	msg ("Plotting nMDS with palette...")
	pdf (file=plotFile, width=7, height=6)
		npoints = seq (1,n,1)
		x = pointsData [npoints,1]
		y = pointsData [npoints,2]

		layout(matrix(1:2,ncol=2), width = c(2.0,0.6),height = c(1,1))
		par(mar = c(4,4,2,0)+0.1)
		plot (x,y, col=xColors, type="p", pch=16, cex=0.5,
			 cex.axis=1.5,cex.lab=2.0, bty="l")

		# plot heatmap
		par(mar = c(3,0.2,1,0))
		plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', cex.main=1)
		#text(x=1, y = seq(0,100,l=1), labels = seq(0,100,l=1))
		legend_image <- as.raster(as.matrix(rev (xColors), ncol=1))
		rasterImage(legend_image, 1, 0, 1.5,1)
		xLabels = formatC (xValues, format="d", width=nchar(toString(n)))
		text(x=-0.1, y = seq(0.02,0.98, l=5), labels = xLabels, 0, cex=1.5)
		text(x=1.8, y = 0.5, labels=c("Folding steps"),srt=90, cex=2.0)
	dev.off()
}

#----------------------------------------------------------
# Rename old file if it exists (old-xxxxxx)
#----------------------------------------------------------
plotTrajectory <- function (scoresPDBsFile, xColors, xValues) {
	name = strsplit (scoresPDBsFile, "[.]")[[1]][1]
	plotFile = paste (basename(name), "-palette.pdf", sep="")

	msg ("Reading scores file: ", scoresPDBsFile, "...")
	scoresData = read.table (scoresPDBsFile, header=F)
	n = nrow (scoresData)
	x = seq (n)
	y = scoresData [,2]

	msg ("Plotting trajectory with palette...")
	pdf (file=plotFile, width=14, height=4)
		layout(matrix(1:2,ncol=1), widths = c(2,2),heights = c(2.5,0.5))
		par (mar=c(4,4.5,0,0)+0.1)
		plot (x,y, type="l", pch=16,cex=0.8, xlab="Folding steps", ylab="TM-scores", bty="l",
			 cex.axis=1.5,cex.lab=2.0, xaxt="n" )
		axis (1, at=xValues, labels=xValues, cex.axis=1.5)
		#text (values, par("usr")[3]-0.2, labels=values, pos=1, xpd=T)

		#Heat map
		legend_image <- as.raster(matrix(xColors, nrow=1))
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
