#!/usr/bin/python

USAGE="\
Extracts n PDBs files from a directory \
USAGE: extract-pdbs.py <inputDir> <number of PDBs>\n"

import os, sys, math
#SIZEBIN  = 100   # Number of files for each bin

#--------------------------------------------------------
# Main function to be called from command line
#--------------------------------------------------------
def main (args):
	if len (args) < 2:
		print USAGE
		sys.exit (1)

	inputDir  = "%s/%s" % (os.getcwd (), args [1])
	name      = os.path.basename (inputDir).split (".")[0]
	ini   = 1
	end   = int (args [2]) 
	outputDir = "%s-%s" % (name, end)

	createDir (outputDir)

	copyFiles (inputDir, outputDir, ini, end)

#--------------------------------------------------------
# Copy or make links for the PDBs
#--------------------------------------------------------
def copyFiles (inputDir, outputDir, ini, end):
	inputFiles  = getSortedFilesDir (inputDir, ".pdb")
	outFilename = "%s.pdbs" % outputDir
	n = len (inputFiles)
	subList = inputFiles [ini-1:end]

	#filePDBs = open (outFilename, "w")
	#filePDBs.write ("%s\n" % inputDir)
	for filename in subList:
		sourceFilename  = "%s/%s" % (inputDir, filename)
		destinyFilename = "%s/%s" % (outputDir, filename)
		os.symlink (sourceFilename, destinyFilename)
		#filePDBs.write (filename+"\n")
		#os.system ("cp %s %s" % (sourceFilename, destinyFilename))

#------------------------------------------------------------------
# Utility to create a directory safely.
# If it exists it is renamed as old-dir 
#------------------------------------------------------------------
def createDir (dir):
	def checkExistingDir (dir):
		if os.path.lexists (dir):
			headDir, tailDir = os.path.split (dir)
			oldDir = os.path.join (headDir, "old-" + tailDir)
			if os.path.lexists (oldDir):
					checkExistingDir (oldDir)

			os.rename (dir, oldDir)
	checkExistingDir (dir)
	os.system ("mkdir %s" % dir)
#--------------------------------------------------------------------
# Get the files containing the pattern from a inputDir 
#--------------------------------------------------------------------
def getSortedFilesDir (inputDir, pattern=""):
	files  = [x for x in os.listdir (inputDir) if pattern in x ]
	return sorted (files)
#--------------------------------------------------------------------
# Call main with input parameter
#--------------------------------------------------------------------
if __name__ == "__main__":
	main (sys.argv)
