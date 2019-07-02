# Extract PDBs from MultiPDB
extract-pdbs-multiPDB.py 

# Reconstruct PDBs using pulchra

# Convert each PDB to XTC gromacs xtc trayectory
gmx trjconv -f p01.pdb  -o p01.xtc

# Concat XTCs files into one
gmx trjcat -f p0* -o pall.xtc

# Create clusters
gmx cluster -f pall.xtc -s pdbs-multiPDBs.pdb -cutoff 0.6 -dist dist -g -cl
