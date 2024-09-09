# based on conda-forge linux image
FROM mambaorg/micromamba:jammy-cuda-12.6.0

LABEL org.opencontainers.image.source=https://github.com/Becksteinlab/streaming-md-docker
LABEL org.opencontainers.image.description="Containers for IMD streaming from MD engines"
LABEL org.opencontainers.image.licenses=MIT

COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install --yes --file /tmp/env.yaml && \
    micromamba clean --all --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1  

# setup GMX 
RUN git clone -b heekun_testruns https://github.com/HeydenLabASU/imd-test.git
RUN cd imd-test/gromacs-2023.5 && mkdir build && cd build && cmake .. -DGMX_GPU=CUDA -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON && make && make check && sudo make install && source /usr/local/gromacs/bin/GMXRC

