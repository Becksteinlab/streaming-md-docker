#!/bin/bash
export PATH="${PATH}:${CUDA_HOME}/bin"
mamba install git cmake cudatoolkit gcc=11 gxx=11 gfortran=11 zlib wget hdf5 -y
cd /opt/
export HOME_DIR=${PWD}
export CPATH=${CONDA_PREFIX}/include
export NPROC=$(nproc)

# setup GMX 
# git clone https://github.com/HeydenLabASU/imd-test.git
# cd imd-test
# git checkout heekun_testruns
# pwd
# cd gromacs-2023.5 && mkdir build && cd build && cmake .. -DGMX_GPU=CUDA -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME} -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON && make && make check && sudo make install
# source /usr/local/gromacs/bin/GMXRC
# gmx mdrun --help
cd ${HOME_DIR}

# Setup NAMD
git clone https://github.com/amruthesht/namd-3.0.git
cd namd-3.0
tar xf charm-8.0.0.tar
cd charm-8.0.0
./build charm++ multicore-linux-x86_64 -j16 --with-production 
cd ../
wget http://www.ks.uiuc.edu/Research/namd/libraries/fftw-linux-x86_64.tar.gz
tar xzf fftw-linux-x86_64.tar.gz
mv linux-x86_64 fftw
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64-threaded.tar.gz
tar xzf tcl8.5.9-linux-x86_64-threaded.tar.gz
mv tcl8.5.9-linux-x86_64-threaded tcl-threaded
./config Linux-x86_64-g++ --charm-arch multicore-linux-x86_64 --with-fftw3 --with-cuda --with-single-node-cuda
cd Linux-x86_64-g++
make -j ${NPROC}
make install


cd ${HOME_DIR}

# Setup LAMMPS
git clone https://github.com/ljwoods2/lammps.git
cd lammps
mkdir build
cd build
cmake ../cmake/ -D PKG_MISC=yes -D PKG_H5MD=yes
cmake --build .
make install -j ${NPROC}

cd ${HOME_DIR}

# test the installations
gmx mdrun --help
lm