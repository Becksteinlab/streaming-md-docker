#!/bin/bash
# Usage: install_lammps.sh "<cmake opts>" <name> <branch>
#   e.g. install_lammps.sh "-DPKG_GPU=on -DGPU_API=cuda" imdv3 imdv3-benchmarking
# Builds LAMMPS from <branch> and installs it to /opt/lammps-<name>.
LMP_OPTS="${1}"
NAME="${2}"
BRANCH="${3}"

export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)
export LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64

# Setup LAMMPS
SRC_DIR=/opt/src/lammps-${NAME}
git clone --depth 1 --branch "${BRANCH}" https://github.com/Becksteinlab/lammps.git "${SRC_DIR}"
cd "${SRC_DIR}"
mkdir build
cd build
cmake ../cmake/ \
     $(echo ${LMP_OPTS} | sed 's/"//g') \
    -D PKG_MISC=yes \
    -D PKG_H5MD=yes \
    -DCMAKE_INSTALL_PREFIX=/opt/lammps-${NAME} \
    -DCMAKE_LIBRARY_PATH="/usr/local/cuda/lib64;${CONDA_PREFIX}/lib" \
    -DCMAKE_INCLUDE_PATH="/usr/local/cuda/include;${CONDA_PREFIX}/include"
cmake --build . -j ${NPROC}
make install
