library (bio3d)

dcdfile <- system.file("examples/hivp.dcd", package="bio3d")
pdbfile <- system.file("examples/hivp.pdb", package="bio3d")

dcd <- read.dcd(dcdfile)
pdb <- read.pdb(pdbfile)

ca.inds <- atom.select(pdb, elety="CA")

xyz <- fit.xyz(fixed=pdb$xyz, mobile=dcd,
               fixed.inds=ca.inds$xyz,
               mobile.inds=ca.inds$xyz)

# PCA computation
pc <- pca.xyz(xyz[,ca.inds$xyz])
plot(pc, col=bwr.colors(nrow(xyz)) )

# Clustering computation
hc <- hclust(dist(pc$z[,1:2]))
grps <- cutree(hc, k=2)
plot(pc, col=grps)

# to examine the contribution of each residue to the first two principal components.
plot.bio3d(pc$au[,1], ylab="PC1 (A)", xlab="Residue Position", typ="l")
points(pc$au[,2], typ="l", col="blue")
