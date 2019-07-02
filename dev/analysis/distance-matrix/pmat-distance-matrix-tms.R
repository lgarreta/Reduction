#!/usr/bin/Rscript

USAGE="/
Calculate the distance matrix of a set of PDBs using the TM-score metric/
USAGE: <distance-matrix-mp.R <PDBs input dir> [ncores] => output.pma\n"


library (parallel)
library (MASS)      # write.matrix: To write matrix to file 
library (rlist)     # save and load lists (matLst)
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

	pdbsDir       = args [1] 
	nCores      = as.numeric (args [2])
	name        = basename (pdbsDir)
	outFilename = paste (name, ".pmat", sep="")

	pdbsLst <<- list.files (pdbsDir, pattern=".pdb", full.names=T)
	distMat = calcPmat (pdbsLst, nCores, name)
	write.matrix (distMat, outFilename)
}
#--------------------------------------------------------------
# Calculate the distance matrix using multicores
#--------------------------------------------------------------
calcPmat <- function (pdbsFilenames, nCores, name) {	
	pairsFile   = paste (name, ".pairs", sep="")

	pdbsLst <<- pdbsFilenames
	nPDBs  = length (pdbsLst)

	cat (">>>> nPDBs: ", nPDBs,"\n")
	cat (">>>> nCores: ", nCores,"\n")

	#-----------------------------------
	# Create pairs to calc distances
	# [[1 2][2 3]....[10 11]]
	#-----------------------------------
	pairsFile = paste (name, ".pairs", sep="")
	matLst = createLoadUpperMatrixPairsList (nPDBs, nCores, pairsFile)

	cat ("\n>>>>>> matlst\n")
	print (length(matLst))

	#-----------------------------------
	# Calculate distances
	#-----------------------------------
	cat ("\nCalculating distance matrices...\n")
	n = length (matLst)
	dmat = matrix (ncol=nPDBs, nrow=nPDBs)
	for (k in seq(n)) {
		#cat ("\n>>> Row ", k, ":", "\n")
		mat = matLst [[k]]
		ls= lapply(seq_len(nrow(mat)), function(i) mat[i,])
		#outRow = unlist (mclapply (ls, calcDistVectors, mc.cores=nCores))
		outRow = unlist (mclapply (ls, calculateTmscore, mc.cores=nCores))
		frow = c(rep(0,k),outRow)
		dmat [k,] = frow
	}
	dmat [n+1,] = rep (0, n+1)

	cat ("\nTransposing distance matrix...\n")
	tdmat =  t(dmat)
	
	cat ("\nWriting distances matrix...\n")
	distMat = as.dist (tdmat, upper=F)

	return (distMat)

}
 

#--------------------------------------------------------------
# Calculate pairwise using TM-score distance
#--------------------------------------------------------------
calcDistVectors <- function (l) {
	#distMat = proxy::dist (l[[1]],l[[2]], method=calculateTmscore, upper=F)
	print (l[[1]])
	print (l[[2]])
	quit()

	distMat = proxy::dist (l[[1]],l[[2]], method=calculateTmscore, upper=F)
	#cat (".")
	return (distMat[1,1])
}

#--------------------------------------------------------------
#--------------------------------------------------------------
#calculateTmscore <- function (target, reference) {
calculateTmscore <- function (l) {
	target    = l[[1]]
	reference = l[[2]]
	if (target == 0 && reference == 0)
		return (0)
	results = .Fortran ("gettmscore", pdb1=pdbsLst[target], pdb2=pdbsLst[reference],  resTMscore=0.4)
	strVal =  paste (round (results$resTMscore,3))
	return (strVal)
}

#--------------------------------------------------------------
# Create a list with the upper matrix pairs (row, col) 
# [[1 2][2 3]....[10 11]]
#--------------------------------------------------------------
createLoadUpperMatrixPairsList <- function (nPDBs, nCores, pairsFile){
	if (file.exists (pairsFile)) {
		cat ("\n>>> Loading pairs file: ", pairsFile, "\n")
		matLst = list.load (pairsFile, type="JSON")
	}else{
		cat ("\n>>> Creating pairs list: ", pairsFile, "\n")
		is = seq (1, nPDBs-1)
		js = seq (2, nPDBs)
		ls = mapply (function (x,y) return (list(c(x,y))), is, js)

		matLst = mclapply (ls, initVectorMat,  nPDBs, mc.cores=nCores)
		#list.save (matLst, pairsFile, type="JSON")
	}

	return (matLst)
}
#--------------------------------------------------------------
#--------------------------------------------------------------
initVectorMat <- function (li, nPDBs){
	i = li [1]
	j = li [2]
	rows = rep (i, nPDBs - j + 1)
	cols = seq (j, nPDBs)
	ls = mapply (function (x,y) return (list(c(x,y))), rows, cols)
	mat = matrix (unlist(ls), ncol=2, nrow=length(ls),byrow=T)
	return (mat)
}

#--------------------------------------------------------------
#--------------------------------------------------------------
main ()
