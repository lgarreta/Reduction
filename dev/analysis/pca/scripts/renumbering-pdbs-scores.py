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
	pdbs, scores = [(x.strip(), "") for x in open (pdbsFilename).readlines()]
elif ".scores" in pdbsFilename:
	pdbsScoresList = [x.strip() for x in open (pdbsFilename).readlines()]
	pdbs, scores = [], []
	for x in pdbsScoresList:
		p,s = x.split()[0], x.split()[1]
		pdbs.append (p)
		scores.append (s)
else:
	pdbs = ["%s/%s" % (pdbsDir, x) for x in os.listdir (pdbsDir)]
	pdbs.sort()

for name, score in zip(pdbs, scores):
	number = int ( name.split("-")[1].split(".")[0])
	newNumber = str(number+1).zfill(5)
	newName = "villinfh-%s.pdb %s" % (newNumber, score)

	if ".pdbs" in pdbsFilename or ".scores" in pdbsFilename:
		print newName
	else:
		cmm1 = "mv %s %s/%s" % (name, pdbsDir, newName)
		print (cmm1)

