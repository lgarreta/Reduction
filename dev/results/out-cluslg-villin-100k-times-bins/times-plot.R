#!/usr/bin/Rscript


data = read.table ("times-bins-v100k.txt", header=T)

bins   = data [,1]
times1 = data [,2]
times2 = data [,3]
times3 = data [,4]

CEX=1.0
pdf ("times-villin-100k-bins.pdf", width=6, height=5)
	plot  (x=bins, y=times1, type="o", pch=15, col="black", lty=1,axes=F, las=1, asp=1,
	       xlab="Tamaño bins", ylab="Tiempo (Segs)", main="Tiempos por tamaño de los bins", cex.lab=CEX, cex.axis=CEX)
	lines (x=bins, y=times2, type="o", pch=16, col="blue",  lty=2)
	lines (x=bins, y=times3, type="o", pch=17, col="red",   lty=4)

	axis (side=1, at=c(0,100,200,400,600,800,1000), labels = T, las=0, cex.axis=CEX, line=0)
	axis (side=2, at=c(12,50,100,200,300,400,500), labels = T, las=1, cex.axis=CEX, line=0)

	box (bty="o")

	legend (x="right", title="Tiempos", c("Total", "Local", "Global"), 
			col=c("black", "blue", "red"), pch=15:17, lty=c(1,2,4))
dev.off()
