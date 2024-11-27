# Set environment variables during runtime.
ARG CUDA_VER
ARG DISTRO_ARCH
ARG DISTRO_VER
FROM --platform=linux/${DISTRO_ARCH} nvidia/cuda:${CUDA_VER}-devel-ubi${DISTRO_VER} as conda

# Set `ARG`s during runtime.
ARG CUDA_VER
ARG DISTRO_ARCH
ARG DISTRO_VER
ENV CUDA_VER=${CUDA_VER} \
    DISTRO_ARCH=ubi \
    DISTRO_NAME=${DISTRO_NAME} \
    DISTRO_VER=${DISTRO_VER}

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Set path to CUDA install (this is a symlink to /usr/local/cuda-${CUDA_VER})
ENV CUDA_HOME /usr/local/cuda

# bust the docker cache so that we always rerun the installs below
ADD https://loripsum.net/api /opt/docker/etc/gibberish

# Add qemu in here so that we can use this image on regular linux hosts with qemu user installed
ADD qemu-aarch64-static /usr/bin/qemu-aarch64-static
ADD qemu-ppc64le-static /usr/bin/qemu-ppc64le-static

# we want to persist a path in ldconfig (to avoid having to always set LD_LIBRARY_PATH), but *after* the existing entries;
# since entries in ld.so.conf.d have precedence before the preconfigured directories, we first add the latter to the former
# the upstream images all have libcuda.so under $CUDA_HOME/compat;
# add this to the ldconfig so it will be found correctly.
# don't forget to update settings by running ldconfig
RUN ldconfig -v 2>/dev/null | grep -v ^$'\t' | cut -f1 -d":" >> /etc/ld.so.conf.d/cuda-$CUDA_VER.conf && \
    echo "$CUDA_HOME/compat" >> /etc/ld.so.conf.d/cuda-$CUDA_VER.conf && \
    ldconfig

# Add the archived repo URL and fix RPM imports
ADD rpm-repos /tmp/rpm-repos
ADD fix_rpm /opt/docker/bin/fix_rpm
RUN /opt/docker/bin/fix_rpm

# Add custom `yum_clean_all` script before using `yum`
COPY yum_clean_all /opt/docker/bin/

# Install basic requirements.
RUN yum update -y --disablerepo=cuda && \
    yum install -y \
        bzip2 \
        sudo \
        tar \
        which \
    && \
    /opt/docker/bin/yum_clean_all

# Fix locale in UBI 8 images
# See https://github.com/CentOS/sig-cloud-instance-images/issues/154
RUN yum install -y \
        glibc-langpack-en \
    && \
    /opt/docker/bin/yum_clean_all; 

# Remove preinclude system compilers
RUN rpm -e --nodeps --verbose gcc gcc-c++

# Run common commands
COPY run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

# Download and cache CUDA related packages.
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -n test --yes --quiet --download-only \
        conda-forge::cudatoolkit=${CUDA_VER} \
        && \
    conda clean -tiy && \
    chgrp -R lucky /opt/conda && \
    chmod -R g=u /opt/conda

# Add a file for users to source to activate the `conda`
# environment `base`. Also add a file that wraps that for
# use with the `ENTRYPOINT`.
COPY entrypoint_source /opt/docker/bin/entrypoint_source
COPY entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `base`.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]

FROM conda AS build

ARG LMP_OPTS=""
ARG GMX_OPTS=""

COPY . .
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create --file env.yaml
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate env && ./install_lammps.sh "$LMP_OPTS"
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate env && ./install_gromacs.sh "$GMX_OPTS"

# Delete the heavy environment but keep conda binaries
RUN source /opt/conda/etc/profile.d/conda.sh && conda remove -n env --all -y
RUN source /opt/conda/etc/profile.d/conda.sh && conda clean -a -y

ARG CUDA_VER
ARG DISTRO_ARCH
ARG DISTRO_VER
# CUDA toolkit is massive, so use a smaller image for the runtime
FROM --platform=linux/${DISTRO_ARCH} ubuntu:plucky

COPY . .
COPY --from=build /opt/docker/bin/run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

COPY --from=build /opt/docker/bin/entrypoint /opt/docker/bin/entrypoint
COPY --from=build /opt/docker/bin/entrypoint_source /opt/docker/bin/entrypoint_source

# Create the new lightweight env
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create --file runtime_env.yaml

COPY --from=build /opt/gromacs_build /opt/gromacs_build
RUN ln -s /opt/gromacs_build/bin/gmx /bin/gmx

COPY --from=build /opt/lammps_build /opt/lammps_build
RUN ln -s /opt/lammps_build/bin/lmp /bin/lmp
