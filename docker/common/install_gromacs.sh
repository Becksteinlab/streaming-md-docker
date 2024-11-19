#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export NPROC=$(nproc)
export LIBRARY_PATH=$LIBRARY_PATH:${CONDA_PREFIX}/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}/lib

git clone https://github.com/hcho38/gromacs.git
cd gromacs
git checkout imd-v3
mkdir build
cd build
cmake .. $(echo ${1} | sed 's/"//g') -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME} -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DCMAKE_INSTALL_PREFIX=/opt/gromacs_build -DCMAKE_CXX_FLAGS="-L${CONDA_PREFIX}/lib -I${CONDA_PREFIX}/include"
make -j ${NPROC}
make install -j ${NPROC}

