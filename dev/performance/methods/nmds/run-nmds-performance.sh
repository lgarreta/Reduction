alias timeu='/usr/bin/time -f "\t%e user"'
timeu -o t0.time nmds.R t00100 4
timeu -o t1.time nmds.R t00200 4
timeu -o t2.time nmds.R t00500 4
timeu -o t3.time nmds.R t01000 4
timeu -o t4.time nmds.R t02000 4
timeu -o t5.time nmds.R t05000 4
timeu -o t6.time nmds.R t07000 4
timeu -o t7.time nmds.R t10000 4
timeu -o t8.time nmds.R t12000 4
timeu -o t9.time nmds.R t15000 4
