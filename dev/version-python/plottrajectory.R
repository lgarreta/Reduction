#!/usr/bin/Rscript

# LOG: Added read/writing scores

library (parallel)
#tmscorelib = sprintf ("%s/%s", Sys.getenv("HOME_PPATH"), "/Reduction/dev/bin/tmscorelg.so")
#cat ("\n>>> tmscoreslib: ", tmscorelib, "\n")
dyn.load ("tmscorelg.so")

options (warn=0)

nCores=4
projectName="standard"


# Creates a .pdf plot for a protein trajectory o pathway
# The input is either a compressed (.tgz) trajectory or
# a directory name with the PDBs files inside it.
USAGE="USAGE: plottrajectory.R <Input dir with PDB Files> <Native PDB File> \n"
#--------------------------------------------------------------
# Main function
#--------------------------------------------------------------
main <- function () {
	message ("Plotting protein folding trajectory...")
	args = commandArgs (TRUE)
	if (length (args) < 2) {
		cat (USAGE)
		quit ()
	}
	pathname   = args [1]
	label      = args [2]
	filenames  = getInOutNames (pathname)
	inDir      = filenames$inDir
	pdbNames   = filenames$pdbNames
	outFile    = filenames$outFile
	scoresFile = filenames$scoresFile

	if (length (args) == 1) {
		scores = getScores (pathname)
	}else {
		proteinNative    = args [2]
		scores = calculateScores (inDir, pdbNames, proteinNative, nCores, scoresFile)
	}

	if (projectName == "gromacs") 
		plotPathwayGromacs (scores, outFile)
	if (projectName == "paper") 
		plotPathwayPaper (scores, outFile, label)
	if (projectName == "inkscape") 
		plotPathwayInkscape (scores, outFile)
	if (projectName == "standard") 
		plotPathway (scores, outFile)

}

#--------------------------------------------------------------
#--------------------------------------------------------------
getScores <- function (pathname){
	cat ("\nLoading scores from ", pathname, "...\n")
	scoresTable = read.table (pathname)
	scores = scoresTable 
	return (scores)
}	
#--------------------------------------------------------------
#--------------------------------------------------------------
calculateScores <- function (pathname, pdbNames, proteinNative, nCores, scoresFile){
	if (file.exists (scoresFile) == TRUE) {
		cat ("\nLoading scores from ", scoresFile, "...\n")
		scoresTable = read.table (scoresFile)
		scores = scoresTable 
	}else {	
		cat ("\nLoading PDBs from ", pathname, "...\n")
		pdbFiles   = getPDBFiles (pathname)
		#pdbFiles  = paste0 (pathname,"/",pdbNames)
		for (x in pdbFiles[1:5]) print(x)

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
#-------------------------------------------------------------
plotPathwayPaper <- function (scores, outFile, label) {
	cat ("\nPaper plotting of scores to ", outFile, "\n")
	cat ("width=20, cex.axis=2, cex.lab=2.5, margins\n")
	pdf (outFile, width=20, height=5.0, compress=T)
		n = nrow(scores)
		rd = scores[,2]
		time = 0:(n-1)
		par (mar=c(4.2,4.6,1.0,2)+0.1)
		plot(time, rd, typ = "l", ylab = "TM-score", xlab = "Time steps (ps)", 
			 ylim=range(c(0,0.6)),bty="l",
			 axes=T,cex.axis=2.0,cex.lab=2.5, cex.main=2)
		mtext (label, side=1, line=-2, cex=2.5, col="red")

	dev.off ()
}


#-------------------------------------------------------------
#-------------------------------------------------------------
plotPathway <- function (scores, outFile) {
	cat ("\nStandard plotting of scores to ", outFile, "\n")
	cat ("width=15\n")
	pdf (outFile, width=15, compress=T)
		n = nrow(scores)
		rd = scores[,2]
		time = 0:(n-1)
		plot(time, rd, typ = "l", ylab = "TM-score", xlab = "Time steps")
			 #cex.axis=1.5,cex.lab=1.5,
		     #mar=c(5,4,2,2)+0.4, bty="l",
			 #axes=TRUE, ylim=range(c(0,0.6)))

	dev.off ()
}

#------------------------------------------------------------
# 
#------------------------------------------------------------
plotPathwayGromacs <- function (scores, outFile) {
	cat ("\nGromacs: Plotting scores to ", outFile, "\n")
	pdf (outFile, width=15, compress=T)
		n = nrow (scores)
		rd = scores[,2]
		time = 1:(n) 
		par (mar=c(5,5,2,2)+0.1)
		plot(time, rd, typ = "l", 
			 cex.axis=2, bty="l", ann=F,
		     mar=c(5,9,2,2)+1, lwd=3, 
			 axes=F, ylim=range(c(0,1.0)))
		title (ylab="TM-score", cex.lab=2.5, line=3.3)
		title (xlab="Time steps", cex.lab=2.5, line=3.8)

		x = seq (0, n, 100)
		xt = paste ("t_", x, sep="")
		axis (side=1, at = x, labels=xt, cex.axis=2)
		y = seq (0, 1, 0.2)
		axis (side=2, at = y, labels=y, cex.axis=2)
	dev.off ()
}

#------------------------------------------------------------
# For Inkscape: big labels and titles. Custom axis
#------------------------------------------------------------
plotPathwayInkscape <- function (scores, outFile) {
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
getInOutNames <- function (pathname) {
	pdbNames = list()
	if (grepl ("gz", pathname)==T) {
		inDir = strsplit (pathname, split="[.]")[[1]][1]
		name  = strsplit (pathname,split="[.]")[[1]][1]
	}
	else if (grepl (".pdbs", fixed=T, pathname)==T) {
		names = readLines (pathname)
		inDir = names [1]
		pdbNames = tail (names, -1)
		#inDir   = readLines (pathname, n=1)
		#inDir   = sprintf ("%s/%s", dirname (pathname), "pdbs")
		name = strsplit (pathname,split="[.]")[[1]][1]
	}
	else if (grepl (".scores", fixed=T, pathname)==T) {
		inDir  = sprintf ("%s/%s", dirname (pathname), "pdbs")
		name   = strsplit (pathname,split="[.]")[[1]][1]
		pdbNames=NULL
	}
	else {  
		inDir = pathname
		name = pathname
	}
	print (pathname)
	print (inDir)
	print (name)

	outFile = sprintf ("%s.pdf", basename (name))
	scoresFile = sprintf ("%s.scores", basename (name))
	return (list (inDir=inDir, pdbNames=pdbNames, outFile=outFile, scoresFile=scoresFile))
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
