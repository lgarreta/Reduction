#!/usr/bin/Rscript

data = read.table ("times-villin-100k-cores.txt", header=T)

#times=c(977, 491, 245, 197, 130, 126, 166, 73, 70, 60)
cores = data [,1]
times = data [,2]

#y = seq(0,1000,200)
#cores=c(1, 2, 4, 5, 8, 10,20,30,40)
#x = c (0,2,5,10, 15,20,30,40)
CEX=1.5
pdf ("times-villin-100k-cores.pdf", width=7, height=7)
	par (mar=c(4,4.6,1.0,0.5)+0.1)
	plot (cores, times, typ="b", xlab="Number of processors (cores)", 
	      ylab="Time (Secs)", axes=T, cex.lab=CEX+0.2, cex.axis=CEX)
	text (x=5, y=977, labels=c("1 core "), cex=CEX)
	text (x=7, y=491, labels=c("2 cores"),cex=CEX)
	text (x=9, y=245, labels=c("4 cores"),cex=CEX)
	text (x=12, y=150, labels=c("8 cores"),cex=CEX)
	axis (side=2, at=c(60), labels=c(60), cex.axis=CEX)

	core0="Cores, Speedup, Time (secs)"
	core1="core,  1x, 971 secs "
	core2="cores, 2x, 491 secs "
	core4="cores, 4x, 245 secs "
	core8="cores, 8x, 130 secs "
	#legend (x=13.2,y=1013, title="Speedup", c(core1, core2, core4, core8), cex=CEX+0.5, xjust=0, bg="gray95",
	#		pch=c("1","2","4","8"))
			#col=c("black", "blue", "green", "red"), pch=15:18, lty=c(1,1,1,1), cex=CEX)
			#col=c("black", "blue", "green", "red"), pch=15:18, lty=c(1,1,1,1), cex=CEX)
	#par (cex.axis = CEX, cex.sub=CEX, cex.main=2)
	#y = c(60,70,80,100,1000)
	#axis (side=2, at=y, labels = T)
	#text (y = times, par("usr")[1], labels = times, srt = 0, pos = 2, xpd = TRUE)
	#axis (side=1, at=x, label=x)
dev.off()
