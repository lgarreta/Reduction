#!/usr/bin/Rscript
#!/home/mmartinez/bin/Rscript

# LOG: 
#	r2.0 (Aug17): Changed distance matrix calculation, now direct call using proxy::dist 
#	r1.4 (Aug16): Modified clustering with initial medoids including the last pdb
#	r1.3 (Aug13): Fixed error when it gets number of pdbs < K
#	r1.2 (Aug3): Extracts K medoids and users TM-score instead RMSD

#----------------------------------------------------------
# Makes a detailed global clustering of protein conformations 
# from the representatives resulting from the local clustering 
# INPUT:  inputDir filename with the protein conformations
#         outputDir filename to write the results
#
# OUTPUT: Medoids for each bin cluster and their distance matrix
#----------------------------------------------------------
USAGE="USAGE: global.R <inputDir> <outputDir> <tmpDir> <K> <num cores>\n" 

#library (bio3d)
library (parallel)
library (cluster)
dyn.load ("tmscorelg.so")

options (width=300)

#THRESHOLD = 1.3
#NCORES= 1

#----------------------------------------------------------
# Main function
#----------------------------------------------------------
main <- function () {
	args <- commandArgs (TRUE)
	cat ("\n\n\n>>>>>>>>>>>>>>>>>>>> Main of Global Reduction...\n")
	cat ("args: ", args, "\n")
	#args = c("io/out1000/outbins", "io/out1000/outrepr", "1.5", "1")
	if (length (args) < 4){
		cat (USAGE)
		cat (length(args))
		quit (status=1)
	}

	INPUTDIR  = args [1] 
	OUTPUTDIR = args [2]
	K         = as.numeric (args [3])
	NCORES    = as.numeric (args [4])

	#createDir (OUTPUTDIR)

	listOfBinPaths    = list.files (INPUTDIR, pattern=".pdbs", full.names=T)
	clusteringResults = mclapply (listOfBinPaths, reduceGlobal, K, mc.cores=NCORES)

	writeClusteringResults (clusteringResults, OUTPUTDIR)
}

#----------------------------------------------------------
# Reduction function to reduce a single bin
# Clustering around medoids. Return k medoid for the bin
#----------------------------------------------------------
reduceGlobal <- function (inputBinPath, K) {
	cat ("\n>>> Global Reducing ", inputBinPath )

	# Fast clustering for bin, writes representatives to clusDir
	#listOfPDBPaths <<- list.files (inputBinPath, pattern=".pdb", full.names=T)
	pdbsDir = paste (dirname (dirname (inputBinPath)),"/pdbs",sep="")
	listOfPDBPaths <<- paste (pdbsDir, readLines(inputBinPath), sep="/")


  # Clustering around medoids. Return one medoid for all inputs
	nPdbs = length (listOfPDBPaths)
	if (nPdbs < 2)
		medoids = 1
	else if (nPdbs <= K)
		medoids = seq (nPdbs)
	else {
		binDir = inputBinPath
		cat ("\n>>> Calculating distance matrix", inputBinPath,"\n")
		distanceMatrix <- getTMDistanceMatrix (listOfPDBPaths)
		split          <- -1 * nPdbs / K
		initialMedoids <- round (seq (nPdbs, 1, split))
		pamPDBs        <- pam (distanceMatrix, k=K, diss=F, medoids=initialMedoids)
		medoids        <- pamPDBs$id.med
	}

	medoidName <- listOfPDBPaths [medoids]
	return (medoidName)
}

#--------------------------------------------------------------
# Calculate pairwise using TM-score distance
#--------------------------------------------------------------
getTMDistanceMatrix <- function (listOfPDBPaths) {
	n = length (listOfPDBPaths)
	mat = matrix (seq (1,n))

	distMat = proxy::dist (mat, method=calculateTmscore)
	return (distMat)
}

#----------------------------------------------------------
# Calculate the TM-scores using a external tool "TMscore"
#----------------------------------------------------------
calculateTmscore <- function (targetProtein, referenceProtein) {
	targetProtein    = listOfPDBPaths [[targetProtein]]
	referenceProtein = listOfPDBPaths [[referenceProtein]]

	results = .Fortran ("gettmscore", pdb1=targetProtein, pdb2=referenceProtein,  resTMscore=0.4)
	tmscoreValue = results$resTMscore

	return  (tmscoreValue)
}

#----------------------------------------------------------
# Make links of the selected PDBs into the output dir
#----------------------------------------------------------
writeClusteringResults <- function (clusteringResults, outputDir) {
	listOfPDBs = c ()
	reductionDir = paste0(outputDir, "/reduction")
	createDir (reductionDir)
	for (binResults in clusteringResults) 
		for (pdbPath in binResults) {
			#cmm <- sprintf ("ln -s %s/%s %s/%s", getwd(), pdbPath, outputDir, basename (pdbPath))
			listOfPDBs = append (listOfPDBs, pdbPath)
			file.copy (pdbPath, reductionDir)
			#cat (paste (">>> ", cmm, "\n"))
			#system (cmm)
		}
	filename = sprintf ("%s/tmp/%s", outputDir, "pdbsGlobal.pdbs")
	listOfPDBs = sort (listOfPDBs)

	listOfPDBs = paste ("tmp/pdbs/", basename(listOfPDBs),sep="")
	write.table (listOfPDBs, file=filename, sep="\n",col.names=F, row.names=F, quote=F)
}

#----------------------------------------------------------
# Create dir, if it exists the it is renamed old-XXX
#----------------------------------------------------------
createDir <- function (newDir) {
	checkOldDir <- function (newDir) {
		name  = basename (newDir)
		path  = dirname  (newDir)
		if (dir.exists (newDir) == T) {
			oldDir = sprintf ("%s/old-%s", path, name)
			if (dir.exists (oldDir) == T) {
				checkOldDir (oldDir)
			}

			file.rename (newDir, oldDir)
		}
	}

	checkOldDir (newDir)
	system (sprintf ("mkdir %s", newDir))
}

#--------------------------------------------------------------
#--------------------------------------------------------------
main () 
