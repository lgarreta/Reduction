#!/usr/bin/Rscript
USAGE="\nCalculate a hierarchical clustering  for a PDBs trajectory (xyz matriz)
USAGE: pca-clust-analysis-fviz.R <xyz trajectory matrix file> => 2D plot file\n\n"

library (bio3d)
library (MASS)      # write.matrix: To write matrix to file 
library (factoextra) # fviz_cluster

options(width=300)
args <-commandArgs (TRUE)
#args = c("pca-villinfhr-reduced3k.xyz")

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

	msg ("Reading xyz matrix...", xyzFile)
	xyzMatrix = as.matrix (read.table (xyzFile))
	n = nrow (xyzMatrix)

	msg ("Computing PCA anlysis...")
	pc <<- pca.xyz (xyzMatrix)
	pcs = pc$z[,1:2]
	#pc$z[,2] = -1*pcs [,2]
	pcs [,2] = -1*pcs [,2]
	variances = pc$sdev^2/sum(pc$sdev^2)
	propVariances = round (variances *100, 2)

	msg ("Writing PCA results...", pcaFile, pcaPropVarFile)
	write.table (pc$z, pcaFile)
	write.table (propVariances, pcaPropVarFile)

	#calcNumberClusters (pcs)
	hc = hcut_cluster (pcs, propVariances, name)

	#silhouetteAnalisys (hc, name)

}

#-------------------------------------------------------------
#-------------------------------------------------------------
silhouetteAnalisys <- function (hc, name) {
	msg ("Calculating silhouette...")
	silhFile    = paste(name, "-clus-hc-fviz-silhouette.pdf", sep="")
	fviz_silhouette (hc)
	ggsave (silhFile)
}

#-------------------------------------------------------------
#
#-------------------------------------------------------------
hcut_cluster  <- function (pcas, propVariances, name) {
	pcas <- as.data.frame (pcas) 
	print (pcas [1:5,])
	msg ("hcut (fviz) clustering PCA results...")
	pdfFileGroups    = paste(name, "-clus-hc-fviz-groups.pdf", sep="")
	pdfFileDendogram = paste(name, "-clus-hc-fviz-dendogram.pdf", sep="")
	pdfFileData      = paste(name, "-clus-hc-fviz.data", sep="")
	pdfFileCluster   = paste(name, "-clus-hc-fviz.cluster", sep="")
	pca2 = pcas [,1:2]
	pca2 [,2] = -1*pca2[,2] 

	labPC1 = paste ("PC1 (", propVariances[1], "%)", sep= "")
	labPC2 = paste ("PC2 (", propVariances[2], "%)", sep= "")

	hc <<- hcut (pca2, k=7, hc_method="complete")

	msg ("Writing hcut cluster...", pdfFileData)
	write.table (hc$cluster, pdfFileCluster)
	msg ("Writing hcut data...", pdfFileData)
	write.table (hc$data, pdfFileData)

	#msg ("Plotting hcut dendogram...")
	#	fviz_dend(hc, show_labels = FALSE, rect = TRUE)
	#ggsave (pdfFileDendogram)

	msg ("Plotting hcut groups")
	fviz_cluster(hc, ellipse.type = "convex", geom=c("point"), 
				 xlab=labPC1, ylab=labPC2, legend="none", main=NULL,
				 show.clust.cent=T, font.x = c(20, "plain", "black"),
				 font.y = c(20, "plain", "black"),
				 font.tickslab = c(16, "plain", "black")
				 )

	#renameOldFile (pdfFileGroups)
	ggsave (pdfFileGroups, width=5, height=5)
	return (hc)
}
#-------------------------------------------------------------
#-------------------------------------------------------------
calcNumberClusters <- function (df) {
	msg ("Silhouette method...")
	fviz_nbclust(df, kmeans, method = "silhouette")+
	  labs(subtitle = "Silhouette method")
	ggsave ("nbclusters-silhouette.pdf")

	msg ("Gap statistic...")
	# nboot = 50 to keep the function speedy. 
	# recommended value: nboot= 500 for your analysis.
	# Use verbose = FALSE to hide computing progression.
	set.seed(123)
	fviz_nbclust(df, kmeans, nstart = 25,  method = "gap_stat", nboot = 50)+
	  labs(subtitle = "Gap statistic method")
	ggsave ("nbclusters-gap.pdf")

	msg ("Elbow method...")
	fviz_nbclust(df, kmeans, method = "wss") +
		geom_vline(xintercept = 4, linetype = 2)+
	  labs(subtitle = "Elbow method")
	ggsave ("nbclusters-elbow.pdf")

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

