#!/usr/bin/python
import os, sys, os.path
"""
AUTHOR: Luis Garreta 
MAIL: lgarreta@gmail.com
LOG: 
	r1.3 (Aug14): Modified, it creates "pdbs" dir
	r1.2 (Aug3): Added K for global clustering
"""

"""
 Given a trayectory it uses a fast clustering algorith to
 reduce the trayectory to only the main representatives.
 INPUT:  
   <inDir>		An input directory with the trayectory files 
   <outDir>		An output directory with the results (representative files)
   <RMSD threshold> Threshold for local reduction comparisons that uses RMSD
   <Size Bin>		Number of structures for each bin of the partiioned trajectory
   <N Cores>		Number of cores to use for paralelizing the procedure
"""
USAGE  = "\nReduces a trayectory using a fast clustering"
USAGE += "\nUSAGE	: pr00_main.py <inDir> <outDir> <SizeBin> <TMSCORE> <K> <nCores>"
USAGE += "\nExample : pr00_main.py in out 40 0.5 5 4"

# Default values
#threshold = 0.5   # TM-score threshold for comparisons between protein structures"
#SIZEBIN   = 40	# Number of files for each bin
#NCORES	  = 2	  # Number of cores for multiprocessing

#------------------------------------------------------------------
#------------------------------------------------------------------
def main (args):
	p = readCheckParameters (args)

	createDirs (p.inDir, p.pdbsDir, p.outDir)
	writeLog (p.outDir, p.inDir, p.sizeBin, p.threshold, p.k)

	# Split full trajectory in bins (blocks of 1000 pdbs)
	cmm ="p1_createBins.R %s %s %s" % (p.pdbsDir, p.outputDirBins, p.sizeBin)
	print (cmm)
	os.system (cmm) 

	# Get Representatives for each bin
	cmm = "pr02_localReduction.R %s %s %s %s" % (p.outputDirBins, p.outDir, p.threshold, p.nCores)
	print (cmm)
	os.system (cmm)

	# Uses K-Medoids to select K medoids for each local bin
	cmm = "pr03_globalReduction.R %s %s %s %s" % (p.inputDirGlobal, p.outputDirGlobal, p.k, p.nCores)
	print (cmm)
	os.system (cmm)

#------------------------------------------------------------------
#------------------------------------------------------------------
def readCheckParameters (args):
	import argparse
	parser = argparse.ArgumentParser (description="Reduced a protein folding trajectory")
	parser.add_argument ("--inDir", required=True, help="Input directory with the trajectory PDBs (e.g. pdbs2JOF/)")
	parser.add_argument ("--outDir", default="out", help="Output directory to write reduction results (e.g. out2JOF/)")
	parser.add_argument ("--sizeBin", default=10, help="Number of PDB files for each partition or bin (e.g. 500)")
	parser.add_argument ("--k", default=30, help="Number of PDB representatives to select for each partition or bin (e.g. 100)")
	parser.add_argument ("--nCores", default="1", help="Number of cores to run in parallel (e.g. 4)")
	parser.add_argument ("--threshold", default=0.5, help="Threshold to take two protein structures as similar or redundant (e.g. 0.5)")

	args = parser.parse_args ()

	args.outputDirBins	= "%s/tmp/bins" % args.outDir
	args.pdbsDir		= args.outDir + "/tmp/pdbs"
	args.inputDirGlobal	= args.outDir + "/tmp/binsLocal"
	args.outputDirGlobal = args.outDir 

	
	numberOfPDBs         = len (os.listdir (args.inDir)	)
	args.sizeBin         = int (args.sizeBin/100. * numberOfPDBs)
	args.k               = int (args.k/100. * args.sizeBin)

	print "Parameters:"
	print "\t Input dir:          ", args.inDir
	print "\t Output dir:         ", args.outDir
	print "\t TM-score threshold: ", args.threshold
	print "\t Size of bins:       ", args.sizeBin
	print "\t K:                  ", args.k
	print "\t Num of Cores:       ", args.nCores
	print "\n"

	return args
	
#------------------------------------------------------------------
# Utility to create a directory safely and make links of original 
# into a "pdbs" dir whiting output dir
# If output dir exists it is renamed as old-dir 
#------------------------------------------------------------------
def createDirs (inDir, pdbsDir, outDir):
	def checkExistingDir (outDir):
		if os.path.lexists (outDir):
			headDir, tailDir = os.path.split (outDir)
			oldDir = os.path.join (headDir, "old-" + tailDir)
			if os.path.lexists (oldDir):
					checkExistingDir (oldDir)
			os.rename (outDir, oldDir)
	checkExistingDir (outDir)
	os.system ("mkdir -p %s/tmp" % outDir)
	os.system ("ln -s %s/%s %s" % (os.getcwd(), inDir, pdbsDir))
	#os.system ("mkdir %s" % pdbsDir)

	#files = os.listdir (inDir)
	#for filename in files:
		#sourceFilename	= "%s/%s" % (os.path.abspath(inDir), filename)
		#destinyFilename = "%s/%s" % (pdbsDir, filename)
		#os.symlink (sourceFilename, destinyFilename)
#------------------------------------------------------------------
# Call main with input parameter
#------------------------------------------------------------------
#------------------------------------------------------------------
def writeLog (outDir, proteinName, sizeOfBins, threshold, k):   
	inFile = open (outDir+"/params.txt", "a")
	inFile.write ("Protein name: " + os.path.basename (proteinName) + "\n")
	inFile.write ("Size of bins : " + str (sizeOfBins) + "\n")
	inFile.write ("TM-score trhreshold : " + str (threshold) + "\n")
	inFile.write ("K representatives : " + str (k) + "\n")
	inFile.close ()

#------------------------------------------------------------------
if __name__ == "__main__":
	main (sys.argv)
