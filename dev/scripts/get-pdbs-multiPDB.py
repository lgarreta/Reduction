#!/usr/bin/python

USAGE="\
Extract PDBs from a <multiPDB File> from <ini> to <end> \
and write multiPDB File and individual PDB files\n\n\
USAGE: extract-pdbs-multiPDB.py <multi PDB filename> <outDir> < Num processors> [ini] [end]"

import sys, os
import shutil
from multiprocessing import Pool 

#------------------------------------------------------------------
# Main
#------------------------------------------------------------------
def main ():
	args = sys.argv
	print ("Running %s" % args [0])

	if len (args) < 4:
		print USAGE
		sys.exit(0)

	if len (args) == 4 :
		nStart = 1
		nEnd   = 999999999
	else:
		nStart = int (args [4])
		nEnd   = int (args [5])

	filename      = args [1]
	outDir        = args [2]
	numProcessors = int (args [3])

	n = 1
	file = open (filename)

	createDir (outDir)

	# Fill buffer with PDBs
	buffer = []
	bufferList = []
	for line in file:
		if not "END" in line:
			buffer.append (line)
		else:
			if n < nStart:
				n += 1
				buffer = []
				continue
			if n > nEnd:
				break

			bufferList.append (buffer)
			buffer = []
			n = n+1

	# Write buffers to files
	n = len (bufferList)
	nStr = len (str (n))+1
	
	jobs = []
	for k, pdb in enumerate (bufferList):
		strCount = str (k+1)
		bufferFilename = "%s/%s%s.pdb" % (outDir, "p", strCount.zfill (nStr))
		data = [bufferList [k], bufferFilename]
		jobs.append (data)

	# Multiprocessing
	pool = Pool (processes=numProcessors)
	pool.map (writeBufferToFile, jobs)
	pool.close ()
	pool.join ()

	# Check to decide to write multiPDB file
	if nEnd != 999999999:
		multiPDBFile = open (outDir+"-mpdb.pdb", "w")
		for k, pdb in enumerate (bufferList):
			multiPDBFile.writelines (bufferList[k])
			multiPDBFile.write("END\n")

		multiPDBFile.close ()

#------------------------------------------------------------------
# Write Buffer to File
#------------------------------------------------------------------
def writeBufferToFile ((buffer, bufferFilename)):
	print (">>>", "Writing %s..." % bufferFilename)
	pdbOut = open (bufferFilename, "w")
	pdbOut.writelines (buffer)
	pdbOut.close ()

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
