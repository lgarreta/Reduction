#!/usr/bin/Rscript

# LOG: Added read/writing scores

library (parallel)
tmscorelib = sprintf ("%s/%s", Sys.getenv("HOME_PPATH"), "/Reduction/dev/bin/tmscorelg.so")
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
	print (length(args))
	if (length (args) < 3) {
		cat (USAGE)
		quit ()
	}
	proteinNative    = args [1]
	pathname         = args [2]
	outDir        	 = dirname (pathname)
	if (length (args) == 3)
		nCores = args [3]

	filenames  = getInOutNames (pathname, outDir)
	inDir      = filenames$inDir
	outFile    = filenames$outFile
	scoresFile = filenames$scoresFile

	cat ("\n>>> ARGS: ", inDir, outFile, scoresFile,"\n")


	# Extract or load filename to calculate RMSDs
	scores = getScoresPathway (pathname, proteinNative, nCores, scoresFile)

	cat ("\nPlotting scores...\n")
	plotPathway (scores, outFile)
}

#--------------------------------------------------------------
#--------------------------------------------------------------
getScoresPathway <- function (pathname, proteinNative, nCores, scoresFile){
	if (file.exists (scoresFile) == TRUE) {
		cat ("\nLoading scores from ", scoresFile, "...\n")
		scoresTable = read.table (scoresFile)
		scores = scoresTable 
	}else {	
		cat ("\nLoading PDBs from ", pathname, "...\n")
		pdbFiles   = getPDBFiles (pathname)

		cat ("\nCalculating scores...\n")	
		scoresList = mclapply (pdbFiles, calculateTmscore, proteinNative, 
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
calculateTmscore <- function (proteinModel, proteinNative) {
	#proteinModel    = listOfPDBPaths [[proteinModel]]
	#proteinNative = listOfPDBPaths [[proteinNative]]

	results = .Fortran ("gettmscore", pdb1=proteinModel, pdb2=proteinNative,  resTMscore=1.0)
	tmscoreValue = results$resTMscore

	cat (proteinModel, proteinNative, tmscoreValue, "\n")
	return (c(basename (proteinModel), tmscoreValue))
}

#-------------------------------------------------------------
# Creata a XY plot from the RMSD scores of each conformation
#-------------------------------------------------------------
plotPathway <- function (scores, outFile) {
	#pdf (outFile, width=20)

	cat ("\nPlotting scores to ", outFile, "\n")
	pdf (outFile, width=15, compress=T)
		n = nrow (scores)
		rd = scores[,2]
		#time = 0:(n-1)
		time = 1:(n) 
		par (mar=c(5,5,2,2)+0.1)
		plot(time, rd, typ = "l", 
			 cex.axis=2, bty="l", ann=F,
		     mar=c(5,9,2,2)+1, lwd=3, 
			 axes=F, ylim=range(c(0,1.0)))
		title (ylab="TM-score", cex.lab=2.5, line=3.3)
		title (xlab="Time steps", cex.lab=2.5, line=3.8)

		#x = c(0.1, 0.2,0.3, 0.4, 0.6, 0.8, 1,2)
		x = seq (0, n, 100)
		xt = paste ("t_", x, sep="")
		axis (side=1, at = x, labels=xt, cex.axis=2)
		y = seq (0, 1, 0.2)
		axis (side=2, at = y, labels=y, cex.axis=2)
		#points (lowess(time,rd, f=2/10), typ="l", col="red", lty=2, lwd=2)
		#steps = n / 21
		#xPoints = seq (0,n, ceiling (steps))
		#axis (side=1, xPoints)
	dev.off ()
}

#--------------------------------------------------------------
# Get files from three kinds of elements:
#   - Compressed file,
# 	- Input filename of pdbs
#   - Input dirname of pdbs
#--------------------------------------------------------------
getInOutNames <- function (pathname, outDir) {
	if (grepl ("gz", pathname)==T) {
		inDir = strsplit (pathname, split="[.]")[[1]][1]
		name  = strsplit (pathname,split="[.]")[[1]][1]
	}
	else if (grepl (".pdbs", fixed=T, pathname)==T) {
		inDir   = sprintf ("%s/%s", dirname (pathname), "pdbs")
		name = strsplit (pathname,split="[.]")[[1]][1]
	}
	else {  
		inDir = pathname
		name = pathname
	}

	outFile = sprintf ("%s.pdf", name)
	scoresFile = sprintf ("%s.scores", name)
	return (list (inDir=inDir, outFile=outFile, scoresFile=scoresFile))
}
#--------------------------------------------------------------
# Get the PDB files from either a compressed file or a dir
#--------------------------------------------------------------
getPDBFiles <- function (pathname) {
	# Extracts to an inDir 
	if (grepl ("gz", pathname)==T) {
		stemName = strsplit (pathname, split="[.]")[[1]][1]
		inDir = stemName 
		untar (pathname, compressed=T, exdir=inDir)
	}else if (grepl (".pdbs", fixed=T, pathname)==T) {
		data = read.table (pathname, header=F)
		inputFilesFull = sprintf ("%s/%s", dirname (pathname), as.character (data$V1))
	}else{
		print (pathname)
		inputFilesFull = list.files (pathname, full.names=T, pattern=".pdb")
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
