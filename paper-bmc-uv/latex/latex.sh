DOC=bmc_article
#lyx -e latex $DOC.lyx
pdflatex $DOC.tex
bibtex $DOC
pdflatex $DOC
pdflatex $DOC
pdf $DOC.pdf
