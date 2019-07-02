#!/usr/bin/Rscript

USAGE="\nCompute nmds scores using as input the distance matrix\
USAGE: nmds-analysis.R <distance matrix> => <nmds scores file>\n"

options(width=300)
args <-commandArgs (TRUE)

library (factoextra)
library (cluster)
#args = c("test33.dmat")

main <- function (){
	args = c("2RN2CA.pmat")
	if (length (args) < 1) {
		cat (USAGE)
		quit()
	 }

	inDistanceMatrixFile = args [1]

  	distMat = as.dist (log (read.table (inDistanceMatrixFile, header=T)))

	#clustering_analysis (inDistanceMatrixFile)
  	distMat = as.dist (log (read.table (inDistanceMatrixFile, header=T)))

	dbscan_analysis_dbs (inDistanceMatrixFile)

}

#--------------------------------------------------------------
# Compute the nmds and write out the scores
#--------------------------------------------------------------
pam_analysis <- function (inDistanceMatrixFile) {
	name      = strsplit (inDistanceMatrixFile, split=".", fixed=T)[[1]][1]
	pdfFile   = paste (name, ".pdf", sep="")

	distMat <<- as.dist (read.table (inDistanceMatrixFile, header=T))

	pr <<- pam (distMat, 8)
	clusplot (pr, dist=distMat)
	#fviz_cluster (pam.res)

	#fviz_cluster(pam.res$cluster, geom = "point", ellipse.type = "norm")
	#fviz_dist(distMat)
	#gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
	#gradient = list(low = "blue",  mid = "yellow", high = "red"))
}
#--------------------------------------------------------------
#--------------------------------------------------------------
dbscan_analysis_dbs <- function (inDistanceMatrixFile) {
	library (dbscan)

	set.seed (123)
	db <<- dbscan::dbscan(distMat, eps=0.15)
	plot(db$cluster, main = "DBSCAN", frame = FALSE)
}
#--------------------------------------------------------------
#--------------------------------------------------------------
dbscan_analysis_fpc <- function (inDistanceMatrixFile) {
  distMat = as.dist (read.table (inDistanceMatrixFile, header=T))
  
  set.seed (123)
  db <- fpc::dbscan(distMat, eps=0.15, MinPts = 5, method = "dist")
  plot(db, df, main = "DBSCAN", frame = FALSE)
}
#--------------------------------------------------------------
#--------------------------------------------------------------
main ()
