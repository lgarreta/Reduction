#!/usr/bin/Rscript
USAGE="\nCalculate PCAs for a PDBs trajectory (xyz matriz)
USAGE: pca-calc-pcas.R <xyz trajectory matrix file> => pcas file\n\n"

library (bio3d)
library (MASS)      # write.matrix: To write matrix to file 
#library (factoextra) # fviz_cluster

options(width=300)
args <-commandArgs (TRUE)
#args = c("villinfhr-reduced3k.xyz")

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
	pdfFileClus = paste (basename(name), "-pca-clus.pdf", sep="")

	msg ("Reading xyz matrix...", xyzFile)
	xyzMatrix = as.matrix (read.table (xyzFile))

	msg ("Computing PCA anlysis...")
	pc <<- pca.xyz (xyzMatrix)

	msg ("Writing PCA results...", pcaFile)
	write.table (pc$z, pcaFile)

	#msg ("Plotting PCA results...")
	#renameOldFile(pdfFilePCA)
	#pdf (file=pdfFilePCA)
	#	plot(pc, col=bwr.colors(nrow(xyzMatrix)))
	#dev.off()

	msg ("Clustering PCA results...")
	pcs = pc$z[,1:2]
	#pc$z[,2] = -1*pcs [,2]
	hc <<- hclust(dist(pcs))
	grps <<- cutree(hc, k=3)

	msg ("Plotting clustering results...")
	renameOldFile(pdfFileClus)
	pdf (file=pdfFileClus)
		plot (pc, col=(grps), pch=20, cex.axis=1.5, cex.lab=1.5)
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
main()

