#!/usr/bin/Rscript
USAGE="\nCalculate PCAs for a PDBs trajectory (xyz matriz)
USAGE: pca-run-clustering.R <PCAs file> => plots|clusters|data\n\n"


options(width=300)
args <-commandArgs (TRUE)
args = c("v.pca")
if (length (args) < 1) {
	cat (USAGE)
	quit()
 }

library (bio3d)
library (factoextra) # fviz_cluster

#-------------------------------------------------------------
# Main function
#-------------------------------------------------------------
main <- function () {
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
	pca2 [,2] = -1*pca2[,2] 

	#out <<- hcut (pca2, k=3, hc_method="complete")
	library(cluster)
	out <<- pam (pcas[,1:3], 5)

	msg ("Writing hcut cluster...", pdfFileData)
	write.table (out$cluster, pdfFileCluster)
	msg ("Writing hcut data...", pdfFileData)
	write.table (out$data, pdfFileData)


	#msg ("Plotting hcut dendogram...")
	#	fviz_dend(hc.cut, show_labels = FALSE, rect = TRUE)
	#ggsave (pdfFileDendogram)

	msg ("Plotting hcut groups")
	fviz_cluster(out, ellipse.type = "convex", geom=c("point"), 
				 show.clust.cent=T)

	renameOldFile (pdfFileGroups)
	ggsave (pdfFileGroups)
}

hclust_cluster <- function (pcas, name) {
	pdfFile = paste(name, "-clus-hclus.pdf", sep="")
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

