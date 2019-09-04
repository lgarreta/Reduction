#!/usr/bin/Rscript


args = commandArgs (TRUE)
#args = c("trj-performance-times.csv")

filename    = args [1]
name        = strsplit (filename,split="[.]")[[1]][1]
pdfFilename = paste (name, ".pdf", sep="")

data = read.table (filename, header=T)

xAxis   = data [,1]
times1 = data [,2]
times2 = data [,3]
times5 = data [,4]
times6 = data [,5]
times7 = data [,6]

CEX=1.5
pdf (pdfFilename, width=10, height=7)
	colorsLegend = c("blue", "magenta", "red", "black", "black")

	par (mar=c(4,4.6,1.0,16)+0.1)
	plot  (x=xAxis, y=times1, type="o", pch=15, col=colorsLegend[4], lty=1,axes=F, #las=1, asp=1,
	       xlab="Trajectory length (No. of conformations)", ylab="Runtime (secs)", cex.lab=CEX+0.2, cex.axis=CEX)
	lines (x=xAxis, y=times2, type="o", pch=16, col=colorsLegend[5],  lty=5)
	lines (x=xAxis, y=times5, type="o", pch=19, col="red",   lty=1)
	lines (x=xAxis, y=times6, type="o", pch=20, col="magenta",   lty=1)
	lines (x=xAxis, y=times7, type="o", pch=21, col=colorsLegend[1],   lty=1)

	sizesX  = c(0.1,0.2,0.5,1,5,10,20,30,40,60,80,100)
	labelsX = c(100, 200, 500, paste0 (sizesX[4:12], "k"))
	print (sizesX)
	print (labelsX)
	axis (side=1, at=sizesX*1000, labels = labelsX, las=0, cex.axis=CEX, las=1, line=0)
	#text (x=xAxis, par("usr")[3], labels = xAxis, srt=45, pos=1, xpd=T, offset=1.5, cex=CEX)
	#axis (side=2, at=c(1,50,100,150,180), labels = T, cex.axis=CEX, line=0, las=3)
	axis (side=2, labels = T, cex.axis=CEX, line=0, las=3)

	box (bty="o")

	textsLegend  = c("nMDS", "Clustering", "PCA", "FR1 (1 core)", "FR2 (2 cores)")
	pchsLegend   = c(21, 20,19, 15, 16)
	legend (x="topright", xpd=T, inset = c(-0.45,0), title="Reduction Techniques", textsLegend,
			col=colorsLegend, pch=pchsLegend, lty=c(1,1,1,1,5), cex=CEX)

	text (x=8000, y=240, "nMDS", col=colorsLegend[1], cex=CEX)
	text (x=42000, y=240, "Clustering", col="magenta", cex=CEX)
	text (x=92000, y=240, "FR1", cex=CEX)
	text (x=98000, y=165, "PCA", col="red", cex=CEX)
	text (x=99000, y=130, "FR2", col=colorsLegend[5], cex=CEX)
	#text (x=99000, y=80, "FR4", col="black", cex=CEX)
	#text (x=99000, y=50, "FR8", col="black", cex=CEX)
dev.off()
