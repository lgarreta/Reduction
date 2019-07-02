#!/usr/bin/Rscript

library(ggplot2)
library(ggpubr)
theme_set(theme_pubr())

# Compute the frequency
library(dplyr)
df <- diamonds %>%
  group_by(cut) %>%
  summarise(counts = n())
df

df <- df %>%
  arrange(desc(cut)) %>%
  mutate(prop = round(counts*100/sum(counts), 1),
         lab.ypos = cumsum(prop) - 0.5*prop)
head(df, 4)

df = as.data.frame (read.table ("trj-performance-methods-cores.txt", header=T ))
print (df)

ggdotchart(
  df, x = "Methods", y = "Runtime", xlab = "Methods", ylab = "Runtime (secs)",
  #color = c(4,4,2,4,4,4,4,4), 
  color = "Methods",
  font.legend = c(18, "plain", "black"),
  size = 8,      # Points color and size
  add = "segment",              # Add line segments
  add.params = list(size = 2), 
  palette = "jco",
  sorting = "descending",
  ggtheme =  theme_bw(),
  #ggtheme = theme_pubclean(), 
  font.x = c(24, "bold", "black"),
  font.y = c(24, "bold", "black"),
  font.tickslab = c(18, "plain", "black")
) 

ggsave (file="performance-methods-100k-multi-cores.pdf", width=7, height=5)
