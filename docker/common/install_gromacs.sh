#!/bin/bash
# Usage: install_gromacs.sh "<cmake opts>" <name> <branch>
#   e.g. install_gromacs.sh "-DGMX_GPU=CUDA" imdv3 imdv3-benchmarking
# Builds GROMACS from <branch> and installs it to /opt/gromacs-<name>.
GMX_OPTS="${1}"
NAME="${2}"
BRANCH="${3}"

export PATH="${PATH}:${CUDA_HOME}/bin"
cd /opt/
export HOME_DIR=${PWD}
export NPROC=$(nproc)
export LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:/usr/local/cuda/lib64

SRC_DIR=/opt/src/gromacs-${NAME}
git clone --branch "${BRANCH}" https://gitlab.com/heydenlabasu/streaming-md/gromacs.git "${SRC_DIR}"
cd "${SRC_DIR}"
mkdir build
cd build
cmake .. \
    $(echo ${GMX_OPTS} | sed 's/"//g') \
    -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/gromacs-${NAME} \
    -DCMAKE_LIBRARY_PATH="/usr/local/cuda/lib64;${CONDA_PREFIX}/lib" \
    -DCMAKE_INCLUDE_PATH="/usr/local/cuda/include;${CONDA_PREFIX}/include"
make -j ${NPROC}
# Remove sources/build tree (keeps build layers small)
make install -j ${NPROC} && cd /opt && rm -rf "${SRC_DIR}"
