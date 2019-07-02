#!/usr/bin/Rscript
USAGE="\nCalculate PCAs for a PDBs trajectory (xyz matriz)
USAGE: pca-from-xyz-trajectory.R <xyz matrix file> => pcas file\n\n"

library (bio3d)
library (MASS)      # write.matrix: To write matrix to file 

options(width=300)
args <-commandArgs (TRUE)

#-------------------------------------------------------------
# Main function
#-------------------------------------------------------------
main <- function () {
	if (length (args) < 1) {
		cat (USAGE)
		quit()
	 }

	xyzFile = args [1]
	name = strsplit (xyzFile, "[.]")[[1]][1]
	pcaFile = paste (basename(name), ".pca", sep="")
	pdfFilePCA  = paste (basename(name), "-pca.pdf", sep="")
	pdfFileClus = paste (basename(name), "-clus.pdf", sep="")

	msg ("Reading xyz matrix...", xyzFile)
	xyzMatrix = as.matrix (read.table (xyzFile))

	msg ("Computing PCA anlysis...")
	pc = pca.xyz (xyzMatrix)

	msg ("Writing PCA results...", pcaFile)
	write.table (pc$z, pcaFile)

	msg ("Plotting PCA results...")
	pdf (file=pdfFilePCA)
		plot(pc, col=bwr.colors(nrow(xyzMatrix)))
	dev.off()

	msg ("Clustering PCA results...")
	hc <<- hclust(dist(pc$z[,1:2]))
	grps <- cutree(hc, k=3)

	msg ("Plotting clustering results...")
	pdf (file=pdfFileClus)
		plot(pc, col=grps)
	dev.off()

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
main()

