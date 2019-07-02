#!/usr/bin/python

USAGE="\
Convert the pdbs to xtcs gromacs trayectories\n\n\
USAGE: create-gromacs-trajectory-bins.py <input pdbs dir>  <PDB reference> <outDir> <sizeBin> <num processors>\n\n\
EXAMPLE: create-gromacs-trajectory-bins.py shm/pdbsr 2JOF-native.pdb 100 " 

import os, sys
from multiprocessing import Pool 

#------------------------------------------------------------------
# Main
#----------------------------------------------------------------yy--
def main ():
	args = sys.argv

	numProcessors = 1
	if len (args) < 6:
		print USAGE
		sys.exit (0)

	inDir         = args [1]
	pdbReference  = args [2]
	outDir        = args [3]
	sizeBin       = int (args [4])
	numProcessors = int (args [5])

	createTrajectoryUsingBins (inDir, pdbReference, outDir, sizeBin, numProcessors)

#----------------------------------------------------------------yy--
# Create gromacs trajectory using bins
#----------------------------------------------------------------yy--
def createTrajectoryUsingBins (inDir, pdbReference, outDir, sizeBin, numProcessors):
	inputFiles = os.listdir (inDir)
	inputFiles.sort ()
	n = len (inputFiles)
	nBins = n / sizeBin
	nZeros = len (str(nBins))+1

	xtcsDir        = outDir + "/xtcs"

	createDir (xtcsDir)
	binsDir = xtcsDir
	
	# Creatae bins and copy PDBs to them
	binDirList = []
	for i in range(nBins):
		k = i+1
		binDir = binsDir+"/bin"+str(k).zfill (nZeros)
		
		ini = i * sizeBin 
		end = ini + sizeBin

		filesList = inputFiles [ini:end]

		cmm = "mkdir %s" % binDir
		print (">>>", cmm)
		os.system (cmm)

		jobsList = []
		for file in filesList:
			cmm = "ln -s %s/%s/%s %s" % (os.getcwd (),inDir, file, binDir)
			#print (cmm)
			#os.system (cmm)
			jobsList.append (cmm)
		
		pool = Pool (processes=numProcessors)	
		pool.map (os.system, jobsList)
		pool.close ()
		pool.join ()
		print ""	

		binDirList.append (binDir)

	# Create local traject from bins
	for i, binDir in enumerate (binDirList):
		k = i+1
		xtcDir = binsDir+"/xtc"+str(k).zfill (nZeros)

		iniTime = i * sizeBin
		createGromacsTrajectoryFromPDBs (binDir, pdbReference, xtcDir, numProcessors, iniTime)

	xtcFilename = outDir + "/traj.xtc"
	cmm = "gmx trjcat -f %s/*.xtc -o %s" % (binsDir, xtcFilename)
	print (">>>", cmm)
	os.system (cmm)
	
#----------------------------------------------------------------yy--
# Create gromacs trajectory (.xtc) from PDBs
#----------------------------------------------------------------yy--
def createGromacsTrajectoryFromPDBs (inDir, pdbReference, outDir, numProcessors, iniTime):
	createDir (outDir)

	pdbFilenames = [x for x in os.listdir (inDir)]
	pdbFilenames.sort ()

	#cmm = "gmx trjconv -f %s/%s.pdb -o %s/%s.xtc -t0 %s"
	cmm = "gmx trjconv -f %s/%s.pdb -s %s -o %s/%s.xtc -t0 %s -fit rot+trans < a.txt"

	jobsList = []
	time = iniTime
	for pdb in pdbFilenames:
		name = pdb.split (".")[0]
		cmmFull = cmm % (inDir, name, pdbReference, outDir, name, time)
		print (">>>", cmmFull)
		#os.system (cmmFull)
		jobsList.append (cmmFull)
		time += 1

	pool = Pool (processes=numProcessors)	
	pool.map (os.system, jobsList)
	pool.close ()
	pool.join ()
	print ""	

	dic1 = {"xtcsDir":outDir, "trjName": outDir}
	cmm = "gmx trjcat -f {xtcsDir}/* -o {trjName}".format (**dic1)
	print (cmm)
	os.system (cmm)

#------------------------------------------------------------------
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




