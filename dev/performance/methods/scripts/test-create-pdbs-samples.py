#!/usr/bin/python
USAGE="\n\
Run a script with a list of samples\n\
USAGE: run-test-samples.py <script to run> <pdbs dir>\n"

import os, sys
args = sys.argv

if len (args) < 2:
	print USAGE
	exit ()

pdbsDir = args [1]

samplesSizes = [1000,5000,10000,15000,20000,25000, 30000]

samplesDirList = []
print "echo '>>>>'"
for sample in samplesSizes:
	sampleNumber   = str(sample).zfill (5) 
	sampleDir      = "%s-%s" % (pdbsDir, sampleNumber)
	outputPDBsFile = "%s.names" % sampleDir
	cmm = "get-pdbs-from-path.py %s %s %s" % (pdbsDir, sample, outputPDBsFile)
	samplesDirList.append (sampleDir)
	print cmm

