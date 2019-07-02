#!/usr/bin/Rscript

# LOG: Added read/writing scores

library (parallel)
tmscorelib = sprintf ("%s/%s", Sys.getenv("HOME_PPATH"), "/Reduction/dev/fortran/tmscorenew.so")
cat ("\n>>> tmscoreslib: ", tmscorelib, "\n")
dyn.load (tmscorelib)

options (warn=0)

nCores=1

# Creates a .pdf plot for a protein trajectory o pathway
# The input is either a compressed (.tgz) trajectory or
# a directory name with the PDBs files inside it.
USAGE="plotpath-tmscore.R <Reference Native> <input pathway dir> [nCores=1]\n"
#--------------------------------------------------------------
# Main function
#--------------------------------------------------------------
main <- function () {
	args = commandArgs (TRUE)
	if (length (args) < 2) {
		cat (USAGE)
		quit ()
	}
	referenceProtein = args [1]
	targetProtein    = args [2]

	cat (">>>", referenceProtein, ", ", targetProtein,"\n")
	TM = calculateTmscore (referenceProtein, targetProtein)
	cat (">>>>", TM, "\n")

}

#--------------------------------------------------------------
#--------------------------------------------------------------
getScoresPathway <- function (targetProtein, referenceProtein, nCores, scoresFile){
	if (file.exists (scoresFile) == TRUE) {
		cat ("\nLoading scores from ", scoresFile, "...\n")
		scoresTable = read.table (scoresFile)
		scores = scoresTable 
	}else {	
		cat ("\nLoading PDBs from ", targetProtein, "...\n")
		pdbFiles   = getPDBFiles (targetProtein)

		cat ("\nCalculating scores...\n")	
		scoresList = mclapply (pdbFiles, calculateTmscore, referenceProtein, 
		 			  mc.preschedule=T, mc.set.seed=T, mc.cores=nCores)

		scores = data.frame (matrix (unlist (scoresList), ncol=2, byrow=T))
		cat ("\nWriting scores...\n")
		write.table (scores, file=scoresFile, row.names=F, col.names=F, quote=F)
		scores = read.table (scoresFile)
	}
	return (scores)
}	

#----------------------------------------------------------
# Calculate the TM-scores using a external tool "TMscore"
#----------------------------------------------------------
calculateTmscore <- function (targetProtein, referenceProtein) {
	#targetProtein    = listOfPDBPaths [[targetProtein]]
	#referenceProtein = listOfPDBPaths [[referenceProtein]]

	results = .Fortran ("gettmscore", pdb1=targetProtein, pdb2=referenceProtein,  resTMscore=1.0)
	tmscoreValue = results$resTMscore

	return (c(basename (targetProtein), tmscoreValue))
}
#----------------------------------------------------------
# Calculate the TM-scores using a external tool
#----------------------------------------------------------
old_calculateTmscore <- function (targetProtein, referenceProtein) {
	allArgs = c (referenceProtein, targetProtein)
	output  = system2 ("TMscore", args=allArgs, stdout=T)
	line = output [[17]]
	fields = strsplit (line, split="[ ]+")[[1]]
	value = as.numeric (fields [3])
	return (c(basename (targetProtein), value))
}

#-------------------------------------------------------------
# Creata a XY plot from the RMSD scores of each conformation
#-------------------------------------------------------------
plotPathway <- function (scores, outFile) {
	#pdf (outFile, width=20)

	cat ("\nPlotting scores to ", outFile, "\n")
	pdf (outFile, width=20, compress=T)
		n = nrow (scores)
		rd = scores[,2]
		#time = 0:(n-1)
		time = 1:(n) 
		plot(time, rd, typ = "l", ylab = "TM-score", xlab = "Frame No.", 
			 cex.axis=1.5,cex.lab=1.5,
		     mar=c(5,4,2,2)+0.4,
			 axes=TRUE, ylim=range(c(0,1.0)))

		#x = c(0.1, 0.2,0.3, 0.4, 0.6, 0.8, 1,2)
		#axis (side=2, at = x, labels=x)
		#points (lowess(time,rd, f=2/10), typ="l", col="red", lty=2, lwd=2)
		#steps = n / 21
		#xPoints = seq (0,n, ceiling (steps))
		#axis (side=1, xPoints)
	dev.off ()
}

#--------------------------------------------------------------
#--------------------------------------------------------------
getInOutNames <- function (targetProtein, outDir) {
	if (grepl ("gz", targetProtein)==T) {
		inDir = strsplit (targetProtein, split="[.]")[[1]][1]
		name  = strsplit (targetProtein,split="[.]")[[1]][1]
	}
	else if (grepl (".pdbs", fixed=T, targetProtein)==T) {
		inDir   = sprintf ("%s/%s", dirname (targetProtein), "pdbs")
		name = strsplit (targetProtein,split="[.]")[[1]][1]
	}
	else {  
		inDir = targetProtein
		name = targetProtein
	}

	outFile = sprintf ("%s.pdf", name)
	scoresFile = sprintf ("%s.scores", name)
	return (list (inDir=inDir, outFile=outFile, scoresFile=scoresFile))
}
#--------------------------------------------------------------
# Get the PDB files from either a compressed file or a dir
#--------------------------------------------------------------
getPDBFiles <- function (targetProtein) {
	# Extracts to an inDir 
	if (grepl ("gz", targetProtein)==T) {
		stemName = strsplit (targetProtein, split="[.]")[[1]][1]
		inDir = stemName 
		untar (targetProtein, compressed=T, exdir=inDir)
	}else if (grepl (".pdbs", fixed=T, targetProtein)==T) {
		data = read.table (targetProtein, header=F)
		inputFilesFull = sprintf ("%s/%s", dirname (targetProtein), as.character (data$V1))
	}else{
		print (targetProtein)
		inputFilesFull = list.files (targetProtein, full.names=T, pattern=".pdb")
	}

	return (inputFilesFull)
}

#--------------------------------------------------------------
# Call main function
#--------------------------------------------------------------
log <- function (msgs) {
	cat ("\nLOG: ")
	for (i in msgs){
		cat (i)
		cat ("  ")
	}
}

main ()
