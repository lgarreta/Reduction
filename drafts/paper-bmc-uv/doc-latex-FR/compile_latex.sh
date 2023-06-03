DOC=paperBMC_FoldingReduction_UV
#DOC=`echo $1|cut -d"." -f1`
echo "Document.... " $DOC
pdflatex $DOC.tex
bibtex $DOC
pdflatex $DOC
pdflatex $DOC
pdf $DOC.pdf
