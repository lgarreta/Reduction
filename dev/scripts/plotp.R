#!/usr/bin/Rscript

# LOG: Added read/writing scores

library (parallel)
options (warn=0)

nCores=1

# Creates a .pdf plot for a protein trajectory o pathway
# The input is either a compressed (.tgz) trajectory or
# a directory name with the PDBs files inside it.
USAGE="plotpath-tmscore.R <Reference Native> <input pathway dir> <scoresFile> [nCores=1]\n"
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
	referenceProtein = args [1]
	pathname         = args [2]
	scoresFile       = args [3]
	outputDir        = getwd ()
	if (length (args) == 4)
		nCores = args [4]

	filenames  = getInOutNames (pathname, outputDir)
	inDir      = filenames$inDir
	outFile    = filenames$outFile

	# Extract or load filename to calculate RMSDs
	cat ("\nLoading PDBs from ", pathname, "...\n")
	files      = getPDBFiles (pathname, referenceProtein)
	
	cat ("\nCalculating scores...")	
	scores = calculateTmscoresPathway (files$n, files$native, files$pdbs, nCores, scoresFile)
	print (scores)

	cat ("\nWriting scores...\n")
	write.table (scores, file=scoresFile, row.names=F, col.names=F, sep="\n")

	cat ("\nPlotting scores...\n")
	plotPathway (scores, outFile)
}

#--------------------------------------------------------------
# Calculate the RMSD between two protein structures
#--------------------------------------------------------------
calculateTmscoresPathway <- function (n, native, pdbs, nCores, scoresFile) {
	if (file.exists (scoresFile)) {
		scoresTable = read.table (scoresFile,sep="\n")
		scores = scoresTable [,1]
	}
	else
		scores = mclapply (pdbs, calculateTmscore, native, 
		 			  mc.preschedule=T, mc.set.seed=T, mc.cores=nCores)

	return (scores)
}
	
#----------------------------------------------------------
# Calculate the TM-scores using a external tool
#----------------------------------------------------------
calculateTmscore <- function (targetProtein, referenceProtein) {
	allArgs = c (referenceProtein, targetProtein)
	output  = system2 ("TMscore", args=allArgs, stdout=T)
	for (line in output)
		if (grepl ("TM-score", line)){
			fields = strsplit (line, split="[ ]+")[[1]]
			if (fields [2] == "=") {
				value = as.numeric (fields [3])
				return (value)
			}
	}
	return  (-999999)
}

#-------------------------------------------------------------
# Creata a XY plot from the RMSD scores of each conformation
#-------------------------------------------------------------
plotPathway <- function (scores, outFile) {
	#pdf (outFile, width=20)
	pdf (outFile, width=20)
		n = length(scores)
		rd = scores[1:n]
		time = 0:(n-1)
		plot(time, rd, typ = "l", ylab = "TM-score", xlab = "Frame No.", 
			 cex.axis=1.5,cex.lab=1.5,
		     mar=c(5,4,2,2)+0.4,
			 axes=TRUE, ylim=range(c(0,0.6)))

		#x = c(0.1, 0.2,0.3, 0.4, 0.6, 0.8, 1,2)
		#axis (side=2, at = x, labels=x)
		#points (lowess(time,rd, f=2/10), typ="l", col="red", lty=2, lwd=2)
		#steps = n / 21
		#xPoints = seq (0,n, ceiling (steps))
		#axis (side=1, xPoints)
	dev.off ()
}

#--------------------------------------------------------------
# Get the PDB files from either a compressed file or a dir
#--------------------------------------------------------------
getPDBFiles <- function (pathname, referenceProtein) {

	# Extracts to an inDir 
	if (grepl ("gz", pathname)==T) {
		stemName = strsplit (pathname, split="[.]")[[1]][1]
		inDir = stemName 
		untar (pathname, compressed=T, exdir=inDir)
	} else 
		inDir = pathname

	#inputFiles = list.files (inDir)
	#inputFilesFull = sapply (inputFiles, function (x) paste (inDir, x, sep="/"))
	inputFilesFull = list.files (inDir, full.names=T)
	write.table (inputFilesFull, "inputFiles.table")
	n = length (inputFilesFull)
	#native = inputFilesFull [[n]]
	outfile = paste (inDir, ".pdf", sep="")

	return (list (n=n, native=referenceProtein, pdbs=inputFilesFull, outfile=outfile))
}

#--------------------------------------------------------------
#--------------------------------------------------------------
getInOutNames <- function (pathname, outputDir) {
	if (grepl ("gz", pathname)==T) 
		inDir = strsplit (pathname, split="[.]")[[1]][1]
	else  
		inDir = pathname

	outFile = sprintf ("%s/%s.pdf", outputDir, basename (inDir))
	return (list (inDir=inDir, outFile=outFile))
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
