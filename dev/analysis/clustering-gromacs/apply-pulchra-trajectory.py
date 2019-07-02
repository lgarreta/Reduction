#!/usr/bin/python
import os, sys
args = sys.argv 

USAGE = "Apply pulchra reconstruction to single pdb files\n\n\
USAGE = apply-pulchra-trayectory.py <input dir> <output dir>"


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

#------------------------------------------------------------------
#------------------------------------------------------------------

if (len(args)) < 3:
	print (USAGE)
	sys.exit (0)

inDir  = sys.argv [1]
outDir = sys.argv [2]

createDir (outDir)

files = os.listdir (inDir)
pdbFiles =  filter (lambda x:".pdb" in x, files)

for pdb in pdbFiles:
	name = pdb.split (".")[0]
	newName = "%sr.pdb" % name

	cmm1 = "pulchra %s/%s" % (inDir, pdb)
	cmm2 = "mv %s/%s.rebuilt.pdb %s/%s" % (inDir, name, outDir, newName)
	print ">>>", cmm1
	os.system (cmm1)
	print ">>>", cmm2
	os.system (cmm2)
