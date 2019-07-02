 R CMD SHLIB tmscorelg.f   # For the library

 gfortran -static -O3 -ffast-math -lm -o tmscore TMscore.f   # For the program
