#!/usr/bin/python

USAGE = "Run gromacs clustering from a gromacs trajectory\n\
USAGE = gromacs-rms.py <in trajectory filename> <in reference PDB> <out dir>>"

import os, sys
import subprocess 

def main ():
	args = sys.argv
	if (len (args) < 4):
		print USAGE
		sys.exit (0)

	trajectoryFilename = args [1]
	pdbReference       = args [2]
	outDir             = args [3]

	(dirname, filename) = os.path.split (trajectoryFilename)
	outFilename = "rms"

	createDir (outDir)

	cmm = "gmx rms -f %s -s %s -m %s/%s -o %s/%s" % \
	(trajectoryFilename, pdbReference, dirname, outFilename, outDir, outFilename)
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
