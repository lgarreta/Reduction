#!/usr/bin/python

USAGE="\
Extracts in a dir or file N PDBs files from a directory \
USAGE: get-pdbs-from-path.py <inputDir> <number of PDBs> [output dir[.names]]\n"

import os, sys, math
#SIZEBIN  = 100   # Number of files for each bin

#--------------------------------------------------------
# Main function to be called from command line
#--------------------------------------------------------
def main (args):
	if len (args) < 2:
		print USAGE
		sys.exit (1)

	inputDir   = "%s/%s" % (os.getcwd (), args [1])
	end        = int (args [2]) 
	name       = os.path.basename (inputDir)
	ini        = 1

	outputDir = "%s-%s" % (name, str(end).zfill(5))
	if len(args)==4:
		outputDir = args [3]

	copyFiles (inputDir, outputDir, ini, end)

#--------------------------------------------------------
# Copy or make links for the PDBs
#--------------------------------------------------------
def copyFiles (inputDir, outputDir, ini, end):
	inputFiles  = getSortedFilesDir (inputDir, ".pdb")
	n = len (inputFiles)
	subList = inputFiles [ini-1:end]

	if ".names" in outputDir:
		filePDBs = open (outputDir, "w")
		filePDBs.write ("%s\n" % inputDir)
	else:
		createDir (outputDir)

	for filename in subList:
		sourceFilename  = "%s/%s" % (inputDir, filename)
		destinyFilename = "%s/%s" % (outputDir, filename)
		#filePDBs.write (filename+"\n")
		if ".names" in outputDir:
			filePDBs.write ("%s\n" % filename)
		else:
			#cmm = "cp %s %s" % (sourceFilename, destinyFilename)
			cmm = "ln -s %s %s" % (sourceFilename, destinyFilename)
			print (cmm)
			os.system (cmm)
			#os.system ("cp %s %s" % (sourceFilename, destinyFilename))
			#os.symlink (sourceFilename, destinyFilename)

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
