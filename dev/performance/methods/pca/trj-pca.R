#!/usr/bin/Rscript
USAGE="\nCalculate PCAs for a PDBs trajectory (xyz matriz)
USAGE: trj-pca.R <PDBS filename> => pcas file\n\n"

options(width=300)
args <-commandArgs (TRUE)
if (length (args) < 1) {
	cat (USAGE)
	quit()
 }

library (bio3d)
library (MASS)      # write.matrix: To write matrix to file 
#library (factoextra) # fviz_cluster

#-------------------------------------------------------------
# Main function
#-------------------------------------------------------------
main <- function () {
	pdbsFilename = args [1]
	name = strsplit (pdbsFilename, split="[.]")[[1]][1]
	pcaFile = paste (basename(name), ".pca", sep="")
	pcaPropVarFile = paste (basename(name), ".pvar", sep="")

	msg ("Loading pdbs...")
	#pdbsFilesPaths = paste (pdbsFilesDir, list.files (pdbsFilesDir), sep="/")
	pdbsFilesPaths = loadPDBsFromFile (pdbsFilename)
	print (pdbsFilesPaths [1:5])
	pdb = read.pdb2 (pdbsFilesPaths [[1]])
	nRows = length (pdbsFilesPaths)
	nCols = length (pdb$xyz)

	outPCA = calcPCA (pdbsFilesPaths, nRows, nCols)

	msg ("Writing PCA results...", pcaFile, pcaPropVarFile)
	write.table (outPCA$pcs, pcaFile)
	write.table (outPCA$vars, pcaPropVarFile)
}


calcPCA <- function (pdbsFilesPaths, nRows, nCols) {

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

