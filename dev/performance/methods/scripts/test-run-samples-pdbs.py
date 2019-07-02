#!/usr/bin/python
USAGE="\n\
Run a script with a list of samples\n\
USAGE: run-test-samples.py <script to run> <pdbs dir>\n"

import os, sys
args = sys.argv

if len (args) < 3:
	print USAGE
	exit ()

script  = args [1]
samplesDir = args [2]
samplesList = os.listdir (samplesDir)
samplesList.sort()

print "echo '>>>>'"
cmm = "alias timeu='/usr/bin/time -f \"%e\"'"
print cmm
for sample in samplesList:
	cmm = "timeu -o %s.time %s %s/%s 4" % (sample, script, samplesDir, sample)
	print cmm
