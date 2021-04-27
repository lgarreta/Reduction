list.of.packages <- c("cluster", "parallel","argparse", "proxy")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
