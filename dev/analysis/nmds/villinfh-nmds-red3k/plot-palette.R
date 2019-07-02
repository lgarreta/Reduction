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

#m = metaMDSiter(dmat,engine="isoMDS", parallel = getOption("mc.cores"))
#m = metaMDSiter(dmat,engine="isoMDS", parallel = 4 )
#plot (m, col=heat.colors(429), type="p", pch=16,cex=2)

main <- function () {
	scoresFile = args [1]  # matrix (.pmat) or points (.points)
	name = strsplit (scoresFile, "[.]")[[1]][1]
	ext  = strsplit (scoresFile, "[.]")[[1]][2]

	plotFile = paste (basename(name), "-palette.pdf", sep="")

	msg ("Reading scores file: ", scoresFile, "...")
	scoresData = read.table (scoresFile)

	msg ("Ploting...", plotFile)
	#renameOldFile (plotFile)
	n = nrow (scoresData)
	x = seq (n)
	y = scoresData [,2]
	colors <- rainbow (n, start=0.2)	

	pdf (file=plotFile, width=10)
		layout(matrix(1:2,ncol=1), widths = c(2,2),heights = c(2.5,0.5))
		#par(mar=c(1,3,1,1))
		par (mar=c(4,4.6,2.5,2)+0.1)
		plot (x,y, type="l", pch=16,cex=0.8, xlab="Time steps", ylab="TM-scores")
		#textxy (x,y, labs=x, cex=1)
		#plot(1:20, 1:20, pch = 19, cex=2, col = colfunc(20))

		legend_image <- as.raster(matrix(colors, nrow=1))
		par(mar = c(0,3,1,0))
		plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', cex.main=1.5)
		#text(x=1, y = seq(0,1,l=5), labels = seq(0,1,l=5))
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
