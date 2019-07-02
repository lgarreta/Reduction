#!/usr/bin/python
#!/home/mmartinez/bin/Rscript
import os, sys
from multiprocessing import Pool 
from multiprocessing.dummy import Pool as ThreadPool
from threading import Thread
#----------------------------------------------------------
# Main function
#----------------------------------------------------------
MAT=[]
pdbs = []
def main (): 
	global MAT, pdbs

	print ("Calculating distance matrix...")
	args = sys.argv

	inDir    = args [1] 
	nCores   = int (args [2])

	outFilename = os.path.basename (inDir) + ".distmat"
	print (">>>>", outFilename,"\n")

	pdbs = ["%s/%s" %(inDir,x) for x in os.listdir (inDir)]
	pdbs.sort ()
	n = len (pdbs)

	# Create matrix
	iniMat (n)

	jobs = []
	for y in range (n):
		for x in range (y+1, n):
			par = (x,y)
			jobs.append (par)
	
	pool = Pool (nCores)
	results = pool.map (calcScore, jobs)
	pool.close ()
	pool.join ()

	fillMat (results)
	writeMat (MAT, outFilename)

#----
#----
def fillMat (results):
	global MAT
	for i in results:
		x   = i [0]
		y   = i [1]
		tms = i [2]
		MAT [x][y] =  MAT [y][x] = tms

#----
#----
def calcScore (par):
	global MAT, pdbs
	tms = 0
	x = par [0]
	y = par [1]

	tms = tmscore (pdbs [y], pdbs [x])

	return (x,y, tms)

#----
#----
def iniMat (n):
	global MAT
	for x in range (0,n):
		submat = []
		for y in range (0,n):
			submat.append (0)
		MAT.append (submat)

#----
#----
def printMat (mat):
	n = len (mat)
	for x in range (0,n):
		print  str(x+1),

	print "\n"
	for x in range (0,n):
		for y in range (0,n):
			v  = mat [x][y]
			fv = "%1.4f" % v
			print fv,
		print "\n"

#----
#----
def writeMat (mat, filename):
	fh = open (filename, "w")

	n = len (mat)
	for x in range (0,n):
		fh.write  (str(x+1))
		if x < n-1:
			fh.write  (" ")

	fh.write ("\n")
	for x in range (0,n):
		for y in range (0,n):
			v  = mat [x][y]
			fv = "%1.4f" % v
			fh.write (fv)
			if y < n-1:
				fh.write  (" ")
		fh.write ("\n")
	fh.close ()

#-------------------------------------------------------------
# Return the tmscore value by calling a external program
#-------------------------------------------------------------
def tmscore (pdbReference, pdbTarget, currentDir=None):
    if currentDir == None:
        currentDir = os.getcwd ()

    value = runProgram (["TMscore", pdbReference, pdbTarget, "-rmsd"], currentDir)
    return value

#-------------------------------------------------------------
# Return the tmscore value by calling a external program
# It runs the command and processes the output.
# It get the value using the command line arguments and 
# running on the working dir
#-------------------------------------------------------------
def runProgram (listOfParams, workingDir):
	import subprocess
	#txtLines = subprocess.Popen (listOfParams, cwd=workingDir, stdout=subprocess.PIPE).communicate()[0]
        txtLines = subprocess.check_output(listOfParams, universal_newlines=True)
        value = getValueFromTxtLine (txtLines)

	return value

############## Get Value ARGUMENTS ######################
def getValueFromTxtLine (txtLines):
    for line in txtLines.split("\n"):
        fields = line.split ()
        if "TM-score" in line and fields[1]=="=":
            value = fields [2]
            return float (value)
    return -9999.999



#----
#----
main()


