#!/usr/bin/Rscript

USAGE="/
Calculate the distance matrix of a set of PDBs using the TM-score metric/
USAGE: <distance-matrix-mp.R <PDBs input dir> [ncores] => output.pma\n"


library (parallel)
library (MASS)      # write.matrix: To write matrix to file 
options (width=300)
dyn.load ("tmscorelg.so")

#--------------------------------------------------------------
# Main
#--------------------------------------------------------------
main <- function () {
	print ("Starting distance matrix computation...")
	args <-commandArgs (TRUE)
	if (length (args) < 2){
		cat (USAGE)
		quit()
	}

	inDir    = args [1] 
	nCores   = as.numeric (args [2])

	outFilename = paste (basename (inDir), ".pmat", sep="")
	listOfPDBPaths <<- list.files (inDir, pattern=".pdb", full.names=T)
	nPDBs  = length (listOfPDBPaths)
	chunkSize = 50

	cat (">>>> input: ", inDir,"\n")
	cat (">>>> nPDBs: ", nPDBs,"\n")
	cat (">>>> output: ", outFilename,"\n")
	cat (">>>> nCores: ", nCores,"\n")

	#-----------------------------------
	# split list of PDBs into chunkSize
	#-----------------------------------
	ini=1
	binList = list ()
	cat ("\nCreating chunks of size: ",  chunkSize, "\n")
	while (ini < nPDBs) {
		end = ini + chunkSize - 1

		if (end > nPDBs)
			end = nPDBs

		binList = append  (binList, list (listOfPDBPaths [ini:end]))
		ini = end+1
	}

	#-----------------------------------
	# Create pairs to calc distances
	#-----------------------------------
	n = length (binList)
	ini = 0
	mat = matrix (nrow=nPDBs, ncol=nPDBs, "0 0")
	cat ("\nCreating matrix of pairs...\n")
	ini = 1
	for (j in seq (1, nPDBs)) {
		i = ini+1
		while (i <= nPDBs) {
			mat [i,j] = paste (i,j)
			i = i+1
		}
		ini = ini+1
	}
	pairsVecStr = as.vector (t(mat))

	#-----------------------------------
	# Calculate distances
	#-----------------------------------
	cat ("\nCalculating distances...\n")
	pairsVecLst = mclapply (pairsVecStr, FUN=getValues, mc.cores=nCores)

	mm = mclapply (pairsVecLst, calcDistVectors, mc.cores=nCores)

	dlist = unlist (mm)

	#-----------------------------------
	# Construct matrix
	#-----------------------------------
	k = 1
	cat ("\nConstructing distances matrix...\n")
	mat = matrix (ncol=nPDBs, nrow=nPDBs,0)
	for (i in seq(1, nPDBs)) {
		cols = c()
		for (j in seq(1, nPDBs)) {
			v = dlist [k]
			cols = append (cols, v)
			k = k+1
		}
		mat[i,] = cols
	}

	cat ("\nWriting distances matrix...\n")
	distMat = as.dist (mat, upper=T)
	write.matrix (distMat, outFilename)
}
 
#--------------------------------------------------------------
#--------------------------------------------------------------
getValues <- function (string) {
	strls = strsplit (string, split=" ")
	v1 = 0 + as.integer (strls [[1]][1])
	v2 = 0 + as.integer (strls [[1]][2])
	return (c(v1,v2))
}	
#--------------------------------------------------------------
# Calculate pairwise using TM-score distance
#--------------------------------------------------------------
calcDistVectors <- function (l) {
	x = l[[1]]
	y = l[[2]]
	distMat = proxy::dist (x,y, method=calculateTmscore, upper=T)
	#distMat = Dist (mat, method=calculateTmscore)
	#distMat = Dist (mat, method="euclidean")
	return (distMat)
}

#--------------------------------------------------------------
#--------------------------------------------------------------
calculateTmscore <- function (target, reference) {
	if (target == 0 && reference == 0)
		return (0)

	tv = listOfPDBPaths [target]
	rv = listOfPDBPaths [reference]

	results = .Fortran ("gettmscore", pdb1=tv, pdb2=rv,  resTMscore=0.4)
	tmscoreValue = results$resTMscore
	return (tmscoreValue)
}

#--------------------------------------------------------------
#--------------------------------------------------------------
main ()
