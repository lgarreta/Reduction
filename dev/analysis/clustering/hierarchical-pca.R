#!/usr/bin/Rscript
USAGE="\nCalculate PCAs for a PDBs trajectory (xyz matriz)
USAGE: pca-from-xyz-trajectory.R <xyz matrix file> => pcas file\n\n"

library (bio3d)
library (factoextra) # fviz_cluster

options(width=300)
args <-commandArgs (TRUE)

#-------------------------------------------------------------
# Main function
#-------------------------------------------------------------
main <- function () {
	#args = c("2RN2CA.pca")
	if (length (args) < 1) {
		cat (USAGE)
		quit()
	 }

	pcaFile = args [1]
	name = strsplit (pcaFile, "[.]")[[1]][1]
	pdfFileClus     = paste (basename(name), "-clus.pdf", sep="")

	msg ("Reading pcas... ", pcaFile)
	pcas <<- read.table (pcaFile, header=T)

	msg ("Clustering PCA results...")
	hcut_cluster (pcas, name)
}

hcut_cluster  <- function (pcas, name) {
	msg ("hcut (fviz) clustering PCA results...")
	pdfFileGroups    = paste(name, "-clus-hc-fviz-groups.pdf", sep="")
	pdfFileDendogram = paste(name, "-clus-hc-fviz-dendogram.pdf", sep="")
	pdfFileData      = paste(name, "-clus-hc-fviz.data", sep="")
	pdfFileCluster   = paste(name, "-clus-hc-fviz.cluster", sep="")
	pca2 = pcas [,1:2]

	hc.cut <- hcut (pca2, k=4, hc_method="complete")
	msg ("Writing hcut cluster...", pdfFileData)
	write.table (hc.cut$cluster, pdfFileCluster)
	msg ("Writing hcut data...", pdfFileData)
	write.table (hc.cut$data, pdfFileData)


	#msg ("Plotting hcut dendogram...")
	#	fviz_dend(hc.cut, show_labels = FALSE, rect = TRUE)
	#ggsave (pdfFileDendogram)

	msg ("Plotting hcut groups")
	fviz_cluster(hc.cut, ellipse.type = "convex", show_labels=F, geom="point")
	ggsave (pdfFileGroups)
}

hclust_cluster <- function (pcas, name) {
	pdfFile = paste(name, "-clus-hc", sep="")
	pca2 = pcas [,1:2]
	hc <<- hclust (dist(pca2))
	grps <<- cutree(hc, k=3)

	pdf (file=pdfFile)
		plot(pca2, grps, col=grps)
	dev.off()
}

kmeans_cluster <- function (pcas, name) {
	pdfFile = paste(name, "-clus-km.pdf", sep="")
	msg ("Kmeans clustering PCA results...")
	km <<- kmeans (pcas, 3, nstart=10)

	msg ("Plotting clustering results with fviz...")
	pdf (file=pdfFile)
	#fviz_cluster(km, pcas, ellipse.type = "norm", ellipse=F)
	#gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
	fviz_cluster(km, pcas, stand = TRUE, geom = "point", repel = TRUE, ggtheme = theme_classic(),ellipse=F)
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

