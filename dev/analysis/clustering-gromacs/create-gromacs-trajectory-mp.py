#!/usr/bin/python

USAGE="\
Convert the pdbs to xtcs gromacs trayectories\n\n\
USAGE: create-gromacs-trajectory-mp.py <input pdbs dir>  <PDB reference> <output xtcs dir>\n\n\
EXAMPLE: create-gromacs-trajectory-mp.py shm/pdbsr shm/xtcs"

import os, sys
from multiprocessing import Pool 

#------------------------------------------------------------------
# Main
#------------------------------------------------------------------
def main ():
	args = sys.argv

	numProcessors = 1
	if len (args) < 4:
		print USAGE
		sys.exit (0)
	elif len (args) == 5:
		numProcessors = int (args [4])

	inDir         = args [1]
	pdbReference  = args [2]
	outDir        = args [3]

	createDir (outDir)

	pdbFilenames = [x for x in os.listdir (inDir)]
	pdbFilenames.sort ()

	#cmm = "gmx trjconv -f %s/%s.pdb -o %s/%s.xtc -t0 %s"
	cmm = "gmx trjconv -f %s/%s.pdb -s %s -o %s/%s.xtc -t0 %s -fit rot+trans < a.txt"

	jobsList = []
	time = 1
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




