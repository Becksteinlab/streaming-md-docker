#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)


git clone https://github.com/HeydenLabASU/imd-test.git
cd imd-test
git checkout heekun_testruns
pwd
cd gromacs-2023.5 && mkdir build && cd build && cmake .. -DGMX_GPU=CUDA -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME} -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=/usr/local/gromacs
make -j ${NPROC}
make install