#!/usr/bin/Rscript
#!/home/mmartinez/bin/Rscript

library (parallel)
library (MASS)      # write.matrix: To write matrix to file 
options (width=300)

#----------------------------------------------------------
# Main function
#----------------------------------------------------------
main <- function () {
	print ("Calculating distance matrix...")
	args <-commandArgs (TRUE)

	inDir    = args [1] 
	nCores      = as.numeric (args [2])

	outFilename = paste (basename (inDir), "-distances.mat", sep="")
	cat (">>>>", outFilename,"\n")

	distMat = getTMDistanceMatrix (inDir)

	write.matrix (distMat, outFilename)
}
#--------------------------------------------------------------
# Calculate pairwise using TM-score distance
#--------------------------------------------------------------
library (amap)
getTMDistanceMatrix <- function (inDir) {
	listOfPDBPaths <<- list.files (inDir, pattern=".pdb", full.names=T)

	n = length (listOfPDBPaths)
	mat = matrix (seq (1,n))

	distMat = proxy::dist (mat, method=calculateTmscore)
	#distMat = Dist (mat, method=calculateTmscore)
	#distMat = Dist (mat, method="euclidean")
	return (distMat)

}

#----------------------------------------------------------
# Calculate the TM-scores using a external tool "TMscore"
# 
#----------------------------------------------------------
calculateTmscore <- function (targetProtein, referenceProtein) {
	referenceProtein = listOfPDBPaths [[referenceProtein]] 
	targetProtein    = listOfPDBPaths [[targetProtein]]
	allArgs = c (referenceProtein, targetProtein)
	output  = system2 ("TMscore", args=allArgs, stdout=T)

	lineTMscore = strsplit (output, "\n")[[17]]
	tmscore = strsplit (lineTMscore, "[ ]{1,}")
	return  (as.double (tmscore[[1]][[3]]))
}

main()

