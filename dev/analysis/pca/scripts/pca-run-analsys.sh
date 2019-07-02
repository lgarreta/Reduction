#!/bin/bash
export PATH=$PATH:/home/lg/ppath/Reduction/dev/analysis/pca

echo -e "\nRun the full pca analysis (xyz, pca, clus, pdfs)
USAGE: pca-analsysis.sh <pdbs dir trajectory>\n"

pdbsDir=$1
name=`echo $pdbsDir | cut -d"." -f1`
xyzMatrix=`echo $name.xyz`
pcaMatrix=`echo $name.pca`

cmm="pca-create-trajectory.R $pdbsDir"
echo -e "\n>>>" $cmm
eval $cmm

cmm="pca-calc-pcas.R $xyzMatrix"
echo -e "\n>>>" $cmm
eval $cmm

cmm="pca-run-clustering.R $pcaMatrix"
echo -e "\n>>>" $cmm
eval $cmm

