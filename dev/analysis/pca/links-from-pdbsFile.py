#!/usr/bin/python
import os, sys
USAGE="Create links from pdbs files \
USAGE: links-form-pdbsFile.py < pdbs file > < pdbs dir>" 

args = sys.argv
if len (args) < 3:
	print USAGE
	exit()


pdbsFilename = args [1]
pdbsDir      = args [2]

outDir       = pdbsFilename.split(".")[0]
curDir       = os.getcwd()

cmm1 = "mkdir %s" % outDir
print (cmm1)

for pdbFile in open (pdbsFilename):
	pdbFile = pdbFile.strip()
	cmm2 = "ln -s %s/%s/%s %s/%s" % (curDir, pdbsDir, pdbFile, outDir, pdbFile)
	print(cmm2)

