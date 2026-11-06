# syntax=docker/dockerfile:1

# Defaults match the configuration tested in CI; DISTRO_ARCH defaults to the
# target architecture (the host's unless --platform is given).
ARG TARGETARCH
ARG CUDA_VER=12.4.1
ARG DISTRO_ARCH=${TARGETARCH}
ARG DISTRO_VER=22.04
ARG DISTRO_NAME=ubuntu
FROM --platform=linux/${DISTRO_ARCH} nvidia/cuda:${CUDA_VER}-devel-${DISTRO_NAME}${DISTRO_VER} AS conda

# Set `ARG`s during runtime.
ARG CUDA_VER
ARG DISTRO_ARCH
ARG DISTRO_VER
ARG DISTRO_NAME
ENV CUDA_VER=${CUDA_VER} \
    DISTRO_ARCH=${DISTRO_ARCH} \
    DISTRO_NAME=${DISTRO_NAME} \
    DISTRO_VER=${DISTRO_VER}

# Set an encoding to make things work smoothly.
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Set path to CUDA install (this is a symlink to /usr/local/cuda-${CUDA_VER})
ENV CUDA_HOME=/usr/local/cuda

# we want to persist a path in ldconfig (to avoid having to always set LD_LIBRARY_PATH), but *after* the existing entries;
# since entries in ld.so.conf.d have precedence before the preconfigured directories, we first add the latter to the former
# the upstream images all have libcuda.so under $CUDA_HOME/compat;
# add this to the ldconfig so it will be found correctly.
# don't forget to update settings by running ldconfig
RUN ldconfig -v 2>/dev/null | grep -v ^$'\t' | cut -f1 -d":" >> /etc/ld.so.conf.d/cuda-$CUDA_VER.conf && \
    echo "$CUDA_HOME/compat" >> /etc/ld.so.conf.d/cuda-$CUDA_VER.conf && \
    ldconfig

# Remove preinclude system compilers
RUN apt-get remove -y --purge gcc g++

# Install basic requirements.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bzip2 \
        sudo \
        tar \
        curl \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Run common commands
COPY --chmod=755 run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

# Download and cache CUDA related packages.
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -n test --yes --quiet --download-only && \
    conda clean -tiy && \
    chgrp -R lucky /opt/conda && \
    chmod -R g=u /opt/conda

# Add a file for users to source to activate the `conda`
# environment `base`. Also add a file that wraps that for
# use with the `ENTRYPOINT`.
COPY --chmod=755 entrypoint_source entrypoint /opt/docker/bin/

FROM conda AS build

ARG NAMD_OPTS=""

# Branches of https://gitlab.com/tcbgUIUC/namd built for each IMD version.
ARG NAMD_IMDV2_BRANCH="vanilla-benchmarking"
ARG NAMD_IMDV3_BRANCH="imdv3-benchmarking"

COPY . .
RUN . /opt/conda/etc/profile.d/conda.sh && conda env create --file env.yaml
RUN chmod +x install_namd.sh
# Each build gets its own layer and installs to /opt/namd-<imd version>.
RUN --mount=type=secret,id=NAMD_ACCESS_TOKEN \
    . /opt/conda/etc/profile.d/conda.sh && conda activate env && ./install_namd.sh "$NAMD_OPTS" imdv2 "$NAMD_IMDV2_BRANCH"
RUN --mount=type=secret,id=NAMD_ACCESS_TOKEN \
    . /opt/conda/etc/profile.d/conda.sh && conda activate env && ./install_namd.sh "$NAMD_OPTS" imdv3 "$NAMD_IMDV3_BRANCH"

# Delete the heavy environment but keep conda binaries
RUN . /opt/conda/etc/profile.d/conda.sh && conda remove -n env --all -y
RUN . /opt/conda/etc/profile.d/conda.sh && conda clean -a -y

ARG CUDA_VER
ARG DISTRO_ARCH
ARG DISTRO_VER
ARG DISTRO_NAME
# CUDA toolkit is massive, so use a smaller image for the runtime
FROM --platform=linux/${DISTRO_ARCH} ${DISTRO_NAME}:${DISTRO_VER}

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
    && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/docker/bin/run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

COPY --from=build /opt/docker/bin/entrypoint /opt/docker/bin/entrypoint_source /opt/docker/bin/

# Create the new lightweight env
COPY runtime_env.yaml /tmp/runtime_env.yaml
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda env create --file /tmp/runtime_env.yaml && \
    conda clean -a -y && \
    rm /tmp/runtime_env.yaml

# Re-declare the build args so they can be recorded as image labels / used below.
ARG NAMD_IMDV2_BRANCH="vanilla-benchmarking"
ARG NAMD_IMDV3_BRANCH="imdv3-benchmarking"
# Which version the plain `namd3` command points to.
ARG DEFAULT_IMD_VERSION="imdv3"
# OCI image labels; CI overrides version, created and revision via docker/metadata-action.
# Licenses: MIT (this repository), custom NAMD license (https://www.ks.uiuc.edu/Research/namd/license.html).
ARG IMAGE_VERSION=dev
LABEL org.opencontainers.image.title="streaming-namd-docker" \
      org.opencontainers.image.description="NAMD with IMDv2/IMDv3 streaming (CPU build)" \
      org.opencontainers.image.url="https://github.com/Becksteinlab/streaming-md-docker" \
      org.opencontainers.image.documentation="https://github.com/Becksteinlab/streaming-md-docker#namd-private-image" \
      org.opencontainers.image.source="https://github.com/Becksteinlab/streaming-md-docker" \
      org.opencontainers.image.vendor="Becksteinlab" \
      org.opencontainers.image.licenses="MIT AND LicenseRef-NAMD" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      io.github.becksteinlab.streaming-md.namd-imdv2.branch="${NAMD_IMDV2_BRANCH}" \
      io.github.becksteinlab.streaming-md.namd-imdv3.branch="${NAMD_IMDV3_BRANCH}"

COPY --from=build /opt/namd-imdv2 /opt/namd-imdv2
COPY --from=build /opt/namd-imdv3 /opt/namd-imdv3
RUN ln -s /opt/namd-imdv2/namd3 /bin/namd3-imdv2 && \
    ln -s /opt/namd-imdv3/namd3 /bin/namd3-imdv3 && \
    ln -s /opt/namd-${DEFAULT_IMD_VERSION}/namd3 /bin/namd3

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `base`.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]