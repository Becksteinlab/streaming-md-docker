#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)
export LIBRARY_PATH=${CONDA_PREFIX}/lib
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib

# Setup LAMMPS
git clone https://github.com/ljwoods2/lammps.git
cd lammps
git checkout imd-v3-integration
mkdir build
cd build
cmake ../cmake/  $(echo ${1} | sed 's/"//g') -D PKG_MISC=yes -D PKG_H5MD=yes -DCMAKE_INSTALL_PREFIX=/opt/lammps_build -DCMAKE_CXX_FLAGS="-L${CONDA_PREFIX}/lib -I${CONDA_PREFIX}/include"
cmake --build . -j ${NPROC}
make install
