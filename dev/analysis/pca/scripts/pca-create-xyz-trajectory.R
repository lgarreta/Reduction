#!/usr/bin/Rscript
USAGE="\nCreate a bio3d trajectory (xyz matrix) from PDBs dir
USAGE: create-bio3d-trajectory.R <pdbs dir> => xyz file\n"

library (bio3d)
library (MASS)      # write.matrix: To write matrix to file 

options(width=300)
args <-commandArgs (TRUE)

#-------------------------------------------------------------
# Main function
#-------------------------------------------------------------
main <- function () {
	pdbsFilesDir = args [1]
	matFile = paste (pdbsFilesDir, ".xyz", sep="")

	if (length (args) < 1) {
		cat (USAGE)
		quit()
	 }

	msg ("Loading pdbs...")
	pdbsFilesPaths = paste (pdbsFilesDir, list.files (pdbsFilesDir), sep="/")
	pdb = read.pdb2 (pdbsFilesPaths [[1]])
	nRows = length (pdbsFilesPaths)
	nCols = length (pdb$xyz)

	xyzMat = matrix (nrow=nRows, ncol=nCols)
	i=1

	msg ("Reading pdbs...")
	while (i <= nRows) {
		pdb = read.pdb2 (pdbsFilesPaths [[i]])
		xyzMat [i,] = pdb$xyz
		i = i+1
	}

	msg ("Writing xyx matrix: ", matFile)
	write.matrix (xyzMat, matFile)
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

