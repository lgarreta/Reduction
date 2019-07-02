#!/usr/bin/Rscript

data = read.table ("times-villin-100k-cores.txt", header=T)

times=c(977, 491,   197, 166, 73, 70, 60)
y = seq(0,1000,200)
cores=c(1, 2, 5,10,20,30,40)
x = c (0,2,5,10,20,30,40)
CEX=1.3
pdf ("times-villin-100k-cores.pdf", width=6, height=6)
	plot (cores, times, typ="b", xlab="Nro. Procesadores (Núcleos)", 
	ylab="Tiempo (Segs)", axes=T, main="Times", cex.lab=CEX, cex.axis=CEX)

	#par (cex.axis = CEX, cex.sub=CEX, cex.main=2)
	#y = c(60,70,80,100,1000)
	#axis (side=2, at=y, labels = T)
	#text (y = times, par("usr")[1], labels = times, srt = 0, pos = 2, xpd = TRUE)
	#axis (side=1, at=x, label=x)
dev.off()
