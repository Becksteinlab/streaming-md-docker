#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)

# Setup LAMMPS
git clone https://github.com/ljwoods2/lammps.git
cd lammps
mkdir build
cd build
cmake ../cmake/ -D PKG_MISC=yes -D PKG_H5MD=yes -D PKG_GPU=yes -DCMAKE_INSTALL_PREFIX=/opt/lammps_build
cmake --build . -j ${NPROC}
make install
ln -s /opt/lammps_build/bin/lmp /bin/lmp
