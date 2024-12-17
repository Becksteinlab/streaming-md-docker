#!/bin/bash
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
git clone https://oauth2:$(cat /run/secrets/NAMD_ACCESS_TOKEN)@gitlab.com/tcbgUIUC/namd.git
cd namd
git checkout feature_imdv3
wget https://github.com/charmplusplus/charm/archive/refs/tags/v8.0.0.tar.gz
tar xf v8.0.0.tar.gz
cd charm-8.0.0
./build charm++ multicore-linux-x86_64 -j ${NPROC} \
    --with-production 
cd ../
./config Linux-x86_64-g++ $(echo ${1} | sed 's/"//g') \
    --charm-arch multicore-linux-x86_64 --with-fftw3 \
    --tcl-prefix ${CONDA_PREFIX} \
    --cxx-opts "-I/usr/local/cuda/include -I${CONDA_PREFIX}/include -L/usr/local/cuda/lib64 -L${CONDA_PREFIX}/lib" \
    --cc-opts "-I/usr/local/cuda/include -I${CONDA_PREFIX}/include -L/usr/local/cuda/lib64 -L${CONDA_PREFIX}/lib" \
    --cuda-prefix /usr/local/cuda

cd Linux-x86_64-g++
make -j ${NPROC}

mkdir /opt/namd-build
mv /opt/namd-3.0/Linux-x86_64-g++/namd3 /opt/namd-build/