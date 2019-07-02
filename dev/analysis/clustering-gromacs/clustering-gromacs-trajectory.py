#!/usr/bin/python

USAGE = "Run gromacs clustering from a gromacs trajectory\n\
USAGE = cluster-gromacs.py <trajectory filename> <topology filename> <rms Filename> <outdir> <cutoff>"

import os, sys
import subprocess 

def main ():
	args = sys.argv
	if (len (args) < 6):
		print USAGE
		sys.exit (0)

	trajectoryFilename = args [1]
	topologyFilename   = args [2]
	rmsFilename        = args [3]
	outDir             = args [4]
	cutoff             = args [5]

	(dirname, filename) = os.path.split (trajectoryFilename)
	outFilename = filename.split (".")[0]

	print ">>>", "Creating dir " + outDir
	createDir (outDir)

	outClusterFilename = "%s/%s" % (outDir, "dist")
	dic1 = {"in": trajectoryFilename, 
			"top": topologyFilename,
			"log": outDir+"/clus",
			"rms": rmsFilename,
			"out": outDir+"/clus",
			"cut": cutoff}

	cmm = "echo 8 | gmx cluster -nofit -f {in} -s {top} -dm {rms}  -g {log}  -cutoff {cut} -dist {out} -o {out} -method gromos"

	cmm = cmm.format (**dic1)
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
