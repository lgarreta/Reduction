#!/usr/bin/python

USAGE = "Copy the PDB centers resulting from gromacs clustering\n\
USAGE:   get-pdbs-clustering.py <clustering filename> <pdbs dir> <outdir>\n\
EXAMPLE: get-pdbs-clustering.py shm/clustering/clus/res.log shm/clustering/pdbs shm/clustering/centers"

import os, sys

def main ():
	args = sys.argv
	if (len (args) < 4):
		print USAGE
		sys.exit (0)

	clusterLogFilename = args [1]
	pdbsDir         = args [2]
	outDir          = args [3]

	linesList = open (clusterLogFilename).readlines()
	middleList = []
	for line in linesList[11:]:
		fields = line.split ("|")
		middle = fields [2]
		valuesList = middle.split ()
		if valuesList == []:
			continue

		middlePDB = valuesList [0]
		middleList.append (middlePDB)
	
	createDir (outDir)
	pdbFilenames = os.listdir (pdbsDir)
	pdbFilenames.sort ()

	print ">>>", middleList
	for num in middleList:
		n = int (num) - 1
		cmm = "ln -s %s/%s/%s %s" % (os.getcwd (), pdbsDir, pdbFilenames [n], outDir)
		os.system (cmm)

#------------------------------------------------------------------
# Utility to create a directory safely.
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

#------------------------------------------------------------------
#------------------------------------------------------------------
main ()
