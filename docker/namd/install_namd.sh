#!/bin/bash
# Usage: install_namd.sh "<namd config opts>" <name> <branch>
#   e.g. install_namd.sh "--with-cuda" imdv3 imdv3-benchmarking
# Builds NAMD from <branch> and installs namd3 to /opt/namd-<name>.
NAMD_OPTS="${1}"
NAME="${2}"
BRANCH="${3}"

export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
# set include path to conda
# export CPATH=${CONDA_PREFIX}/include
# # set linker path to conda libs
export LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64
export NPROC=$(nproc)

# Setup NAMD
SRC_DIR=/opt/src/namd-${NAME}
git clone --branch "${BRANCH}" https://oauth2:$(cat /run/secrets/NAMD_ACCESS_TOKEN)@gitlab.com/tcbgUIUC/namd.git "${SRC_DIR}"
cd "${SRC_DIR}"
wget https://github.com/charmplusplus/charm/archive/refs/tags/v8.0.0.tar.gz
tar xf v8.0.0.tar.gz
cd charm-8.0.0
./build charm++ multicore-linux-x86_64 -j ${NPROC} \
    --with-production \
    --libdir=${CONDA_PREFIX}/lib \
    --incdir=${CONDA_PREFIX}/include
cd ../
./config Linux-x86_64-g++ $(echo ${NAMD_OPTS} | sed 's/"//g') \
    --charm-arch multicore-linux-x86_64 --with-fftw3 \
    --tcl-prefix ${CONDA_PREFIX} \
    --cxx-opts "-I/usr/local/cuda/include -I${CONDA_PREFIX}/include -L/usr/local/cuda/lib64 -L${CONDA_PREFIX}/lib" \
    --cc-opts "-I/usr/local/cuda/include -I${CONDA_PREFIX}/include -L/usr/local/cuda/lib64 -L${CONDA_PREFIX}/lib" \
    --cuda-prefix /usr/local/cuda

cd Linux-x86_64-g++
make -j ${NPROC}

mkdir /opt/namd-${NAME}
mv ${SRC_DIR}/Linux-x86_64-g++/namd3 /opt/namd-${NAME}/
