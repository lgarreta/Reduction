INDIR=$1
OUTDIR=out-$1
NATIVE=native_2f4k_Amb_CA.pdb
SIZEBIN=100
TMSCORE=0.6
K=10
NCORES=4
timeu='/usr/bin/time -f "	%e user"'
cmm="pr00_main.py $INDIR $OUTDIR $SIZEBIN $TMSCORE $K $NCORES"
echo $cmm
eval $cmm
