INDIR=shm/villin/v100k
NATIVE=shm/villin/2f4k-native.pdb
OUTDIR=shm/villin/outv100k-$NCORES
SIZEBIN=100
TMSCORE=0.5
K=10
alias timeu='/usr/bin/time -f "\t%U user"'
timeu -o $LOG pr00_main.py $INDIR $OUTDIR $SIZEBIN $TMSCORE $K 45
plotpath-tmscore.R $NATIVE  $OUTDIR/pdbsGlobal.pdbs $NCORES &
plotpath-tmscore.R $NATIVE  $OUTDIR/pdbsLocal.pdbs $NCORES &
