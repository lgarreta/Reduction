PATHWAY=$1
NATIVE=natives/native-`basename $1`.pdb
NCORES=46

echo ">>>" run1.sh NATIVE PATHWAY "<<<"

pr00_main.py $PATHWAY shm/out 500 0.4 10 $NCORES

echo ""
echo ">>>>>>>>>>>>> PLOTTING <<<<<<<<<<<<<<"
echo ""
pathway-plotting-tmscore.R $NATIVE  shm/out/pdbs $NCORES
pathway-plotting-tmscore.R $NATIVE  shm/out/pdbsLocal $NCORES
pathway-plotting-tmscore.R $NATIVE  shm/out/pdbsGlobal $NCORES

mkdir -p shm/out/pdfs
mv pdbs.pdf pdbsLocal.pdf pdbsGlobal.pdf shm/out/pdfs

