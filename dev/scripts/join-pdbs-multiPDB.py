#!/usr/bin/python

USAGE="Join single PDB files into a multiPDB\n\n\
USAGE = join-pdbs-multiPDB.py <input Dir> < |-new|-end >"

import os, sys
args = sys.argv

if len (args) < 2:
	print (USAGE)
	sys.exit (0)
elif len (args) == 2:
	endLine = ""
elif args [2]=="-new":
	endline = "\n"
elif args [2]=="-end":	
	endline = "END\n"

inDir  = args [1]
outFilename = "%s-multiPDBs.pdb" % inDir
outFile     = open (outFilename, "w")

files = ["%s/%s" % (inDir, x) for x in os.listdir (inDir) if x.endswith(".pdb")]
files.sort ()

for pdb in files:
	print ".",
	lines = open (pdb).read()
	newLines = lines+endline

	outFile.write (newLines)

outFile.close ()

