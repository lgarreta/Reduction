#!/usr/bin/Rscript
USAGE="\nCalculate PCAs for a PDBs trajectory (xyz matriz)
USAGE: pca-calc-pcas.R <xyz trajectory matrix file> => pcas file\n\n"

library (bio3d)
library (MASS)      # write.matrix: To write matrix to file 
#library (factoextra) # fviz_cluster

options(width=300)
args <-commandArgs (TRUE)
args = c("pca-villinfhr-reduced3k.xyz")

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
	pcaPropVarFile = paste (basename(name), ".pvar", sep="")
	pdfFilePCA  = paste (basename(name), "-pca.pdf", sep="")
	pdfFileClus = paste (basename(name), "-pca-clus.pdf", sep="")

	msg ("Reading xyz matrix...", xyzFile)
	xyzMatrix = as.matrix (read.table (xyzFile))
	n = nrow (xyzMatrix)
	xcolors = rainbow (n, start=0.2)

	msg ("Computing PCA anlysis...")
	pc <<- pca.xyz (xyzMatrix)
	pcs = pc$z[,1:2]
	pc$z[,2] = -1*pcs [,2]
	variances = pc$sdev^2/sum(pc$sdev^2)
	propVariances = round (variances *100, 2)
	labPC1 = paste ("PC1 (", propVariances[1], "%)", sep= "")
	labPC2 = paste ("PC2 (", propVariances[2], "%)", sep= "")

	msg ("Writing PCA results...", pcaFile, pcaPropVarFile)
	write.table (pc$z, pcaFile)
	write.table (propVariances, pcaPropVarFile)

	msg ("Plotting PCA results...")
	#renameOldFile(pdfFilePCA)
	pdf (file=pdfFilePCA, width=5, height=5)
		par (mar = c(4,4,2,0)+ 0.1)
		plot (pc$z, col=xcolors, pch=20, cex=1, xlab = labPC1, ylab = labPC2,
			  cex.axis=1.5, cex.lab=1.5)
	dev.off()

	msg ("Clustering PCA results...")
	hc <<- hclust(dist(pcs))
	grps <<- cutree(hc, k=5)

	msg ("Plotting clustering results...")
	renameOldFile(pdfFileClus)
	pdf (file=pdfFileClus, width=5, height=5)
		par(mar = c(4,4,2,0))
		#par (mar = c(4,4,1,0)+ 0.1)
		plot (pc$z, col=grps, pch=20, cex=1, xlab = labPC1, ylab = labPC2,
			  cex.axis=1.5, cex.lab=1.5)
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

