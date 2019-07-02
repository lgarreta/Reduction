#!/usr/bin/Rscript

USAGE="
Select a distance submatrix from selected pdbs and full distance matrix
USAGE: <sel-pdbs-from-dmat.R <PDBs file> <distance matrix file> => submatrix file\n"

options(width=300)
args <-commandArgs (TRUE)
if (length (args) < 2) {
	cat (USAGE)
	quit()
}

library (MASS)      # write.matrix: To write matrix to file 

main <- function () {
	pdbsFile = args [1]
	matFile  = args [2]

	name        = strsplit (pdbsFile, "[.]")[[1]][1]
	numbersFile = paste (name, ".numbers", sep="")
	selPdbsFile = paste (name, ".pmat", sep="")

	msg ("Reading pdbs file...")
	pdbsData = read.table (pdbsFile)

	msg ("Gettrin numbers...")
	pdbsNumbers = c()
	for (pdb in pdbsData[,1]) {
		name    = strsplit (pdb, "[.]")[[1]][1]
		number  = strsplit (name, "-")[[1]][2]
		pdbsNumbers = c(pdbsNumbers, as.numeric(number))
	}


	msg ("Reading dmat file...")
	matData  = read.table (matFile, header=T)
	selData  = matData [pdbsNumbers, pdbsNumbers]
	matData  = as.matrix (selData) 
	
	msg ("Writing selectad pdbs to file: ", selPdbsFile)
	write.matrix (matData, selPdbsFile)
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
main ()
