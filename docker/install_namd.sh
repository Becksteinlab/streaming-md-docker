#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)

# Setup NAMD
git clone https://github.com/amruthesht/namd-3.0.git
cd namd-3.0
tar xf charm-8.0.0.tar
cd charm-8.0.0
./build charm++ multicore-linux-x86_64 -j16 --with-production 
cd ../
wget http://www.ks.uiuc.edu/Research/namd/libraries/fftw-linux-x86_64.tar.gz
tar xzf fftw-linux-x86_64.tar.gz
mv linux-x86_64 fftw
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64-threaded.tar.gz
tar xzf tcl8.5.9-linux-x86_64-threaded.tar.gz
mv tcl8.5.9-linux-x86_64-threaded tcl-threaded
./config Linux-x86_64-g++ --charm-arch multicore-linux-x86_64 --with-fftw3 --with-cuda --with-single-node-cuda
cd Linux-x86_64-g++
make -j ${NPROC}
