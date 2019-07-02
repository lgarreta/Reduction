#!/usr/bin/python
import os, sys
args = sys.argv

USAGE  ="Assign scores in one file to names of the second file\n"
USAGE += args [0] + " <File with PDB scores> <File with only names>"

if len (args) < 3:
	print USAGE
	exit (0)

scoresFile = args [1]
namesFile  = args [2]
scoresNames = namesFile.split(".")[0] + ".scores"

scoresDic = {}
for x in open (scoresFile):
	x = x.strip()
	nameValue = x.split()
	name  = nameValue [0]
	value = nameValue [1]
	scoresDic [name] = float(value)

scoresFileHandler = open (scoresNames, "w")

for x in open (namesFile):
	x = x.strip()
	scoresFileHandler.write("%s %s\n" % (x, scoresDic [x]))


