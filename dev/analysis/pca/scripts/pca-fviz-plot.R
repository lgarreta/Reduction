#!/usr/bin/Rscript
USAGE="\nCreate fviz_cluster plot from input cluster and data results.
USAGE: pca-fviz-plot.R <cluster file> <data file> => plots\n\n"


options(width=300)
args <-commandArgs (TRUE)
#args = c("2RN2CA.pca")
if (length (args) < 2) {
	cat (USAGE)
	quit()
 }

library (bio3d)
library (factoextra) # fviz_cluster

#-------------------------------------------------------------
# Main function
#-------------------------------------------------------------
main <- function () {
	clusterFile = args [1]
	dataFile    = args [2]

	name = strsplit (clusterFile, "[.]")[[1]][1]
	pdfFile     = paste (basename(name), "-groups.pdf", sep="")

	msg ("Reading clusters...", clusterFile)
	cluster <- read.table (clusterFile, header=T, row.names=1)

	msg ("Reading data...", dataFile)
	data <- read.table (dataFile, header=T)
	data [,2] = -1*data[,2]

	hc = list(cluster=as.integer(unlist(cluster)),data=data)

	msg ("Plotting cluster groups...")

	fviz_cluster(hc, ellipse.type = "convex", geom=c("point"),
				 show.clust.cent=T)
	renameOldFile (pdfFile)
	ggsave (pdfFile)
}

#-------------------------------------------------------------
# Print a log message with the parameter
#-------------------------------------------------------------
msg <- function (...) {
	messages = unlist (list (...))
	cat (">>>>", messages, "\n")
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
main()

