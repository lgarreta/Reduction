#!/usr/bin/Rscript
USAGE="\nCalculate PCAs for a PDBs trajectory (xyz matriz)
USAGE: trj-clustering.R <PDBs dir> => clusters and data files\n\n"

options(width=300)
args <-commandArgs (TRUE)
if (length (args) < 1) {
	cat (USAGE)
	quit()
 }

library (bio3d)
library (MASS)      # write.matrix: To write matrix to file 
library (factoextra) # fviz_cluster

#-------------------------------------------------------------
# Main function
#-------------------------------------------------------------
main <- function () {
	pdbsFilename = args [1]
	name = strsplit (pdbsFilename, split="[.]")[[1]][1]
	clustersFile   = paste(name, "-clus-hc.cluster", sep="")
	dataFile      = paste(name, "-clus-hc.data", sep="")

	msg ("Reading pdbs names...")
	#pdbsFilesPaths = paste (pdbsFilesDir, list.files (pdbsFilesDir), sep="/")
	pdbsFilesPaths = loadPDBsFromFile (pdbsFilename)

	outPCA = calcPCA (pdbsFilesPaths)
	hc = hcut_cluster (outPCA$pcs, outPCA$vars)

	msg ("Writing hcut cluster...", dataFile)
	write.table (hc$cluster, clustersFile)
	msg ("Writing hcut data...", dataFile)
	write.table (hc$data, dataFile)
}

#-------------------------------------------------------------
# Return PDB paths from PDB names file with path at first line
#-------------------------------------------------------------
loadPDBsFromFile <- function (filenamePDBs) {
	names = readLines (filenamePDBs)
	pathName = names [1]
	pdbsNames = tail (names, -1)

	pdbPaths <- paste0 (pathName, "/", pdbsNames)
	return (pdbPaths)
}

#-------------------------------------------------------------
# Calculate clustering (hcut)
#-------------------------------------------------------------
hcut_cluster  <- function (pcas, propVariances) {
	msg ("Calculating clustering (hcut-fviz) from PCA results...")
	pcas <- as.data.frame (pcas) 
	print (pcas [1:5,])
	pca2 = pcas [,1:2]
	pca2 [,2] = -1*pca2[,2] 

	hc <- hcut (pca2, k=7, hc_method="complete")

	return (hc)
}
#-------------------------------------------------------------
# Calculate PCA
#-------------------------------------------------------------
calcPCA <- function (pdbsFilesPaths) {
	pdb   = read.pdb2 (pdbsFilesPaths [[1]])
	nRows = length (pdbsFilesPaths)
	nCols = length (pdb$xyz)

	msg ("Calculating xyz matrix...")
	xyzMatrix = createXYZMatrix (pdbsFilesPaths, nRows, nCols)
	n = nrow (xyzMatrix)

	msg ("Computing PCA anlysis...")
	pc <- pca.xyz (xyzMatrix)
	pcs = pc$z[,1:2]
	pc$z[,2] = -1*pcs [,2]
	variances = pc$sdev^2/sum(pc$sdev^2)
	propVariances = round (variances *100, 2)

	outPCA = list (pcs=pc$z,  vars=propVariances)
	return (outPCA)

}

#-------------------------------------------------------------
#-------------------------------------------------------------
createXYZMatrix <- function (pdbsFilesPaths, nRows, nCols) {
	xyzMat = matrix (nrow=nRows, ncol=nCols)
	i=1

	msg ("Reading pdbs...")
	while (i <= nRows) {
		pdb = read.pdb2 (pdbsFilesPaths [[i]])
		xyzMat [i,] = pdb$xyz
		i = i+1
	}
	return (xyzMat)
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

