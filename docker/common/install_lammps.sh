#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)
export LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64

# Setup LAMMPS
git clone https://github.com/lammps/lammps.git
cd lammps
git checkout develop
mkdir build
cd build
cmake ../cmake/ \
     $(echo ${1} | sed 's/"//g') \
    -D PKG_MISC=yes \
    -D PKG_H5MD=yes \
    -DCMAKE_INSTALL_PREFIX=/opt/lammps_build \
    -DCMAKE_LIBRARY_PATH="/usr/local/cuda/lib64;${CONDA_PREFIX}/lib" \
    -DCMAKE_INCLUDE_PATH="/usr/local/cuda/include;${CONDA_PREFIX}/include"
cmake --build . -j ${NPROC}
make install
