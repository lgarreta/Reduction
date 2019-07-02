INDIR=outvfh/villinfhr
OUTDIR=outvfh/out
NATIVE=outvfh/native_2f4k_Amb_CA.pdb
SIZEBIN=100
TMSCORE=0.8
K=50
NCORES=4
LOG=outvfh/time-$TMSCORE.log
alias timeu='/usr/bin/time -f "\t%U user"'

/usr/bin/time -f "\t%U user" -o $LOG pr00_main.py $INDIR $OUTDIR $SIZEBIN $TMSCORE $K $NCORES
cmm="plotpath-tmscore.R $OUTDIR/pdbsGlobal.pdbs $NATIVE   $NCORES "
echo $cmm
eval $cmm

cmm="plotpath-tmscore.R $OUTDIR/pdbsLocal.pdbs $NATIVE $NCORES "
echo $cmm
eval $cmm

