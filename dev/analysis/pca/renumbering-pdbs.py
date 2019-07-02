#!/usr/bin/python
import os, sys
args = sys.argv

USAGE="Renumber pdbs filenames from a .pdbs file or pdbs dir\n \
USAGE: renumbering-pdbs.py < pdbs file | pdbs dir > stdout"

if len(args) < 2:
	print USAGE
	exit()

pdbsFilename = args [1]
if ".pdbs" in pdbsFilename:
	pdbs = [x.strip() for x in open (pdbsFilename).readlines()]
else:
	pdbs = ["%s/%s" % (pdbsDir, x) for x in os.listdir (pdbsDir)]
	pdbs.sort()

for name in pdbs:
	number = int ( name.split("-")[1].split(".")[0])
	newNumber = str(number+1).zfill(5)
	newName = "villinfh-%s.pdb" % (newNumber)

	if ".pdbs" in pdbsFilename:
		print newName
	else:
		cmm1 = "mv %s %s/%s" % (name, pdbsDir, newName)
		print (cmm1)

