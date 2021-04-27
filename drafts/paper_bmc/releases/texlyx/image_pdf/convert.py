
import os

files = os.listdir(".")

for f in files:
	name = f.split (".")[0]
	cmm = "convert " + f + " " + name + ".png"
	print cmm
	os.system (cmm)
