#!/usr/bin/Rscript

readCheckParameters <- function (args) {
	library (argparse)
	parser = argparse::ArgumentParser (description="Reduced a protein folding trajectory")
	parser$add_argument ("--inDir", required=TRUE, help="Input directory with the trajectory PDBs (e.g. pdbs2JOF/)")
	parser$add_argument ("--outDir", default="out", help="Output directory to write reduction results (e.g. out2JOF/)")
	parser$add_argument ("--sizeBin", default=10, help="Number of PDB files for each partition or bin (e.g. 500)")
	parser$add_argument ("--k", default=30, help="Number of PDB representatives to select for each partition or bin (e.g. 100)")
	parser$add_argument ("--nCores", default="1", help="Number of cores to run in parallel (e.g. 4)")
	parser$add_argument ("--threshold", default=0.5, help="Threshold to take two protein structures as similar or redundant (e.g. 0.5)")

	args = parser$parse_args (c("--inDir", "CF1K"))

	args.outputDirBins	= sprintf ("%s/tmp/bins", args$outDir)
	args.pdbsDir		= paste0 (args$outDir, "/tmp/pdbs")
	args.inputDirGlobal	= paste0 (args$outDir, "/tmp/binsLocal")
	args.outputDirGlobal = args$outDir 

	numberOfPDBs         = length (list.files (args$inDir))
	args.sizeBin         = args$sizeBin/100. * numberOfPDBs
	args.k               = args$k/100. * args$sizeBin

	message ("Parameters:")
	message ("\t Input dir:          ", args$inDir)
	message ("\t Output dir:         ", args$outDir)
	message ("\t TM-score threshold: ", args$threshold)
	message ("\t Size of bins:       ", args$sizeBin)
	message ("\t K:                  ", args$k)
	message ("\t Num of Cores:       ", args$nCores)
	message ("\n")

	return (args)
}
	
