#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)

# Setup LAMMPS
git clone https://github.com/ljwoods2/lammps.git
cd lammps
git checkout imd-v3
mkdir build
cd build
cmake ../cmake/ ${1} -D PKG_MISC=yes -D PKG_H5MD=yes -DCMAKE_INSTALL_PREFIX=/opt/lammps_build
cmake --build . -j ${NPROC}
make install

