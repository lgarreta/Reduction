#!/usr/bin/Rscript
#!/home/mmartinez/bin/Rscript

# LOG: r1.2 (Aug3): Using TM-score instead RMSD

#----------------------------------------------------------
# Make a fast clustering of protein conformations from a 
# trayectory by doing first a fast local clustering 
# INPUT:  
#   <inputDir>       An input directory with the trayectory files 
#   <outputDir>      An output directory with the results (representative files)
#   <RMSD threshold> Threshold for local reduction comparisons that uses RMSD
#   <Size Bin>       Number of structures for each bin of the partiioned trajectory
#   <N Cores>        Number of cores to use for paralelizing the procedure
#
# OUTPUT:            An output dir with the clustering results for each bin
#----------------------------------------------------------
USAGE="USAGE: reduction.R <inputDir> <outputDir> <TM-score Threshold> <num cores>\n" 
library (parallel)
library (cluster)
dyn.load ("tmscorelg.so")

options (width=300, warn=0, warnings=F, nwarnings=100)

#THRESHOLD = 1.3
#NCORES= 1
#----------------------------------------------------------
# Main function
#----------------------------------------------------------
main <- function () {
	args <- commandArgs (TRUE)
	cat ("\n\n\n>>>>>>>>>>>>>>>>>>>> Local Reduction...\n")
	cat ("args: ", args, "\n")
	#args = c("io/out1000/outbins", "io/out1000/outrepr", "1.5", "1")
	print (args)
	if (length (args) < 4){
		cat (USAGE)
		quit (status=1)
	}

	INPUTDIR  = args [1] 
	OUTPUTDIR = args [2]
	THRESHOLD = as.numeric (args [3])
	NCORES    = as.numeric (args [4])
	dirBins = paste (OUTPUTDIR,"/tmp/binsLocal",sep="")
	dirPdbs = OUTPUTDIR

	createDir (dirBins)

	binPathLst         = list.files (INPUTDIR, pattern=".pdbs", full.names=T)
	clusteringResults  = mclapply (binPathLst, reduceLocal, outputDir=dirBins, 
								        threshold=THRESHOLD,dirPdbs=dirPdbs, mc.cores=NCORES)
	writeClusteringResults (clusteringResults, dirPdbs)
	
}

#----------------------------------------------------------
# Reduction function to reduce a single bin
# Fast clustering following hobbohm algorith
# The first protein in the bin is selected as representative, then
# if the others are differente from it, they are preserved.
# Write the links to the representatives in the output dir
# Return a list with the representative as the first pdb in the group
#----------------------------------------------------------
reduceLocal <- function (inputBinPath, outputDir, threshold, dirPdbs) {
	cat ("\n>>> Local Reducing ", inputBinPath,"\n" )
	# Create the output dir for representatives
	outputBinPath = (paste (getwd(), outputDir, basename (inputBinPath), sep="/"))

	pdbsDir = paste (dirname (dirname (inputBinPath)),"/pdbs",sep="")
	pdbsNames = strsplit (readLines (inputBinPath), split=".pdbs")
	listOfPDBPaths <- paste (pdbsDir, pdbsNames, sep="/")

	# Fast clustering for bin, writes representatives to outputBinPath
	n = length (listOfPDBPaths)
	headProteinPath    = listOfPDBPaths [[n]] # Default head for the first group
	tmscoreValue       = -1                   # To create the link for the first group
	listOfSelectedPdbs = c (basename(headProteinPath))
	k = n - 1
	while (k >= 1) {
		targetProtein = listOfPDBPaths[[k]] 
		results = .Fortran ("gettmscore", pdb1=targetProtein, pdb2=headProteinPath, resTMscore=0.4)
		tmscoreValue = results$resTMscore

		if (tmscoreValue < threshold) {
			listOfSelectedPdbs = append (listOfSelectedPdbs, basename (targetProtein))
			headProteinPath = targetProtein
		}
		k = k - 1
	}

	listOfSelectedPdbs = sort (listOfSelectedPdbs)
	write.table (listOfSelectedPdbs, file=outputBinPath, sep="\n",col.names=F, row.names=F, quote=F)
	return (listOfSelectedPdbs)
}


#----------------------------------------------------------
# Calculate the TM-scores using a external tool "TMscore"
#----------------------------------------------------------
calculateTmscore <- function (targetProtein, referenceProtein) {
	#targetProtein    = listOfPDBPaths [[targetProtein]]
	#referenceProtein = listOfPDBPaths [[referenceProtein]]

	allArgs = c (referenceProtein, targetProtein)
	output  = system2 ("TMscore", args=allArgs, stdout=T)

	lineTMscore = strsplit (output, "\n")[[17]]
	tmscore = strsplit (lineTMscore, "[ ]{1,}")
	value   = (as.double (tmscore[[1]][[3]]))
	return  (value)
}

#----------------------------------------------------------
# Make links of the selected PDBs into the output dir
#----------------------------------------------------------
writeClusteringResults <- function (clusteringResults, outputDir) {
	listOfPDBs = c ()
	for (binResults in clusteringResults) 
		for (pdbPath in binResults) {
			listOfPDBs = append (listOfPDBs, pdbPath)
		}
	filename = sprintf ("%s/tmp/%s", outputDir, "pdbsLocal.pdbs")
	listOfPDBs = sort (listOfPDBs)
	listOfPDBs = paste ("pdbs/", basename(listOfPDBs),sep="")
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
#summary(warnings())
