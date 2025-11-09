#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export NPROC=$(nproc)
export LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64

git clone https://gitlab.com/heydenlabasu/streaming-md/gromacs.git
cd gromacs
git checkout imdv3-sans-tests
mkdir build
cd build
cmake .. \
    $(echo ${1} | sed 's/"//g') \
    -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/gromacs_build \
    -DCMAKE_LIBRARY_PATH="/usr/local/cuda/lib64;${CONDA_PREFIX}/lib" \
    -DCMAKE_INCLUDE_PATH="/usr/local/cuda/include;${CONDA_PREFIX}/include"
make -j ${NPROC}
make install -j ${NPROC}

