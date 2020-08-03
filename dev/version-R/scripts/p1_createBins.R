#!/usr/bin/Rscript

USAGE="
Split the files of an input directory in bins according to the\n
size of the bin. The bins are put in an output directory\n
USAGE: createBins.py <inputDir> <outputDir> <sizeBin>\n"

#import os, sys, math
#SIZEBIN  = 100   # Number of files for each bin

#--------------------------------------------------------
# Main function to be called from command line
#--------------------------------------------------------
main <- function () {
	args = commandArgs(trailingOnly = TRUE)
	#args = c ("out/tmp/pdbs", "out/tmp/bins", "23")
	if (length (args) < 3) {
		message (USAGE)
		quit ()
	}

	inputDir  = sprintf ("%s/%s", getwd (), args [1])
	outputDir = sprintf ("%s/%s", getwd (), args [2])
	SIZEBIN   = as.numeric (args [3]) 

	createDir (outputDir)

	createBins (inputDir, outputDir, SIZEBIN)
}

#--------------------------------------------------------
# Creates bins from files in an input dir 
# outputDir is the destiny dir for bins
# binSize is the number of file by bin
# sizeFill is the prefix for each bin filename
#--------------------------------------------------------
createBins <- function (inputDir, outputDir, binSize) {
	createDir (outputDir)

	inputFiles  = list.files (inputDir, pattern=".pdb")
	n = length (inputFiles)
	sizeFill = nchar (n)
	binList = splitBins (inputFiles, binSize)

	for (k in 1:length(binList)) {
		lst = binList [[k]]
		binNumber = k

		binName = formatC (k, width=sizeFill, format="d", flag=0)
		binDirname = sprintf ("%s/%s%s", outputDir, "bin", binName)
		message (">>> Creating bin ",  binName, "...")

		binFilename = sprintf ("%s.pdbs" , binDirname)
		filenames = unlist (lst)
		writeLines (filenames, binFilename)
	}
}

#--------------------------------------------------------
# Creates a list of sublist where each sublist corresponds to
# the files of each bin
#--------------------------------------------------------
splitBins <- function (inputFiles, binSize) {
	nSeqs = length (inputFiles)
	#nBins = nSeqs / binSize
	nBins = ceiling (nSeqs / binSize)

	binList = list()
	for (k in 0:(nBins-1)) {
		start = k*binSize
		end   = start + binSize 
		if (k < nBins-1) 
			binList = append (binList, list (inputFiles [(start+1):end]))
		else
			binList = append (binList, list (inputFiles [(start+1):nSeqs]))
	}

	return (binList)
}

#------------------------------------------------------------------
# Utility to create a directory safely.
# If it exists it is renamed as old-dir 
#------------------------------------------------------------------
createDir <- function (newDir) {
	checkOldDir <- function (newDir) {
		name  = basename (newDir)
		path  = dirname  (newDir)
		if (dir.exists (newDir) == T) {
			oldDir = sprintf ("%s/old-%s", path, name)
			if (dir.exists (oldDir) == T) 
				checkOldDir (oldDir)
			file.rename (newDir, oldDir)
		}
	}

	checkOldDir (newDir)
	system (sprintf ("mkdir %s", newDir))
}

#--------------------------------------------------------------------
# Call main with input parameter
#--------------------------------------------------------------------

#main ()
