#!/usr/bin/Rscript
#!/home/mmartinez/bin/Rscript

library (parallel)
library (MASS)      # write.matrix: To write matrix to file 
options (width=300)

#----------------------------------------------------------
# Main function
#----------------------------------------------------------
main <- function () {
	print ("Calculating distance matrix...")
	args <-commandArgs (TRUE)

	matFilename = args [1] 

	matData = as.matrix (read.table (matFilename, header=T))


	print (matData)
}

main()

