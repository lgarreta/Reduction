#!/usr/bin/python

USAGE="\
Full process for gromacs clustering from extracting PDBs to clustering\n\n\
USAGE: full-gromacs-clustering.py <multiPDB filename> <pdb reference> <outDir> <cutoff> <size bins> <numProcessors>\n\n\
EXAMPLE: full-gromacs-clustering.py trj-pdbs.pdb native.pdb shm 0.7 100 4"

import os, sys

#------------------------------------------------------------------
#------------------------------------------------------------------
def main():
	args = sys.argv
	if len (args) < 7:
		print USAGE
		sys.exit (0)

	multiPDBFilename = args [1]
	pdbReference     = args [2]
	outDir           = args [3]
	cutoff           = float (args [4])
	sizeBin          = int (args [5])
	numProcessors    = int (args [6])

	topoPDBFilename  = multiPDBFilename

	if (os.path.exists (outDir)):
		trajFilename = "%s/traj.xtc" % outDir
		rmsFilename  = "%s/rms.xpm" % outDir
	else:
		createDir (outDir)

		# Extractx PDBs from multiPDB file
		pdbsDir = "%s/%s" % (outDir, "pdbs")
		dic1 = {"filename": multiPDBFilename, "outDir": pdbsDir, "numProc": numProcessors}
		cmm1 = "extract-pdbs-multiPDB.py {filename} {outDir} {numProc}".format (**dic1)
		print (cmm1)
		os.system (cmm1)


		# Create gromacs trajectory
		dic3 = {"pdbRef": pdbReference, "inDir": pdbsDir, "outDir": outDir, "sizeBin": sizeBin, "numProc": numProcessors}
		cmm3 = "create-gromacs-trajectory-bins.py {inDir} {pdbRef} {outDir} {sizeBin} {numProc}".format (**dic3)
		print (cmm3)
		os.system (cmm3)

		# Calculate rms
		rmsDir       = outDir +"/rms"
		trajFilename = "%s/traj.xtc" % outDir
		rmsFilename  = "%s/rms.xpm" % outDir
		cmm = "gromacs-rms.py %s %s %s < a.txt" % (trajFilename, pdbReference, rmsDir)
		cmm = cmm.format (**dic3)
		print ">>>", cmm
		os.system (cmm)

	# Clustering
	clusDir = outDir+"/clus"+str(cutoff)
	print ">>>clusDir " + clusDir
	dic3 = {"traj": trajFilename,
			"topo": topoPDBFilename,
			"rms" : rmsFilename,
			"outDir": clusDir,
			"cutoff": cutoff}

	cmm = "clustering-gromacs-trajectory.py {traj} {topo} {rms} {outDir} {cutoff} "
	cmm = cmm.format (**dic3)
	print ">>>", cmm
	os.system (cmm)

	# Get PDB centers from gromacs clustering log
	clusterLogFilename = clusDir + "/clus.log"
	pdbsDir            = outDir + "/pdbs"
	middlesDir         = clusDir + "/pdbsc"
	cmm = "get-pdbs-clustering.py %s  %s %s" % (clusterLogFilename, pdbsDir, middlesDir)
	print ">>>", cmm
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
main()
