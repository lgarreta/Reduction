#!/usr/bin/python
import os, sys
args = sys.argv

USAGE="\
Given both minimal and maximal RMSD it gives five RMSDs values in this range\n\n\
USAGE: rmsd-ranges.py <cluster log filename>"

lines   = open (args [1]).readlines ()
rmsLine = lines [2]
avrLine = lines [3]
fields = rmsLine.split ()
min = float (fields [4])
max = float (fields [6])

fields = avrLine.split ()
avr = float (fields [3])

K = 6 

step = (max - min)/K

print "Min: %s, Max: %s, Avr: %s" % (min, max, avr)
for i in range(K+1):
	rms = min + i*step
	print (round (rms,2))
