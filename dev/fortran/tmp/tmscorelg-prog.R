#!/usr/bin/Rscript

# LOG: Added read/writing scores

library (parallel)
tmscorelib = sprintf ("%s/%s", Sys.getenv("HOME_PPATH"), "/Reduction/dev/fortran/tmp/tmscorelg-lib.so")
cat ("\n>>> tmscoreslib: ", tmscorelib, "\n")
dyn.load (tmscorelib)

options (warn=0)

nCores=1

# Creates a .pdf plot for a protein trajectory o pathway
# The input is either a compressed (.tgz) trajectory or
# a directory name with the PDBs files inside it.
USAGE="tmscorelib.R <Reference native> <Target protein> \n"
#--------------------------------------------------------------
# Main function
#--------------------------------------------------------------
main <- function () {
	args = commandArgs (TRUE)
	if (length (args) < 2) {
		cat (USAGE)
		quit ()
	}
	referenceProtein = args [1]
	targetProtein    = args [2]

	#cat (">>>", referenceProtein, ", ", targetProtein,"\n")
	TM = calculateTmscore (referenceProtein, targetProtein)
	cat (">>>", TM$value, "\n")
}

#----------------------------------------------------------
# Calculate the TM-scores using a external tool "TMscore"
#----------------------------------------------------------
calculateTmscore <- function (targetProtein, referenceProtein) {
	#targetProtein    = listOfPDBPaths [[targetProtein]]
	#referenceProtein = listOfPDBPaths [[referenceProtein]]

	results = .Fortran ("gettmscore", pdb1=targetProtein, pdb2=referenceProtein,  resTMscore=1.0)
	resTMscore = results$resTMscore

	return (list(target=basename (targetProtein), value=resTMscore))
}

main ()
