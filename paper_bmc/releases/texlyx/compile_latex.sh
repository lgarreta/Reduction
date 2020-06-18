DOC=paperBMC_main
#lyx -e latex $DOC.lyx
pdflatex $DOC.tex
bibtex $DOC
pdflatex $DOC
pdflatex $DOC
