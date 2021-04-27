#!/bin/bash

# Install pfoldred:
## 1. Add environment into bashrc
## 2. Install local R libraries

sed "/PFOLDRED_HOME/d" -i ~/.bashrc

echo "export PFOLDRED_HOME=$PWD" >> ~/.bashrc

Rscript "INSTALL-R-LIBS.R"

