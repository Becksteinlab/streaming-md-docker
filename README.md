# Containers for IMD streaming

The following builds a container containing LAMMPS and GROMACS ready for use with the IMD v3 streaming interface.
(We also have a version of NAMD with IMDv3 streaming but NAMD's license does not allow us to include it here.)

# Building

The "common" directory contains a Dockerfile which will contain 
both LAMMPS and GROMACS.

The following arguments are required to build the container from source
for a CPU-only build:
```bash
docker buildx build -t streaming_md_docker_local \
    --build-arg GMX_OPTS="" \
    --build-arg LMP_OPTS="" \
    --build-arg CUDA_VER=12.4.1 \
    --build-arg DISTRO_ARCH=amd64 \
    --build-arg DISTRO_VER=22.04 \
    --build-arg DISTRO_NAME=ubuntu \
    ./docker/common
```
These are the values passed in the CI which are tested. Other
build argument configurations are not guaranteed to build succesfully.

After building, you can then run the container using:
```bash
docker run -it streaming_md_docker_local
```

For a GPU-build, you can do:
```bash
docker buildx build -t streaming_md_docker_local \
    --build-arg GMX_OPTS="-DGMX_GPU=CUDA" \
    --build-arg LMP_OPTS="-DPKG_GPU=on -DGPU_API=cuda" \
    --build-arg CUDA_VER=12.4.1 \
    --build-arg DISTRO_ARCH=amd64 \
    --build-arg DISTRO_VER=22.04 \
    --build-arg DISTRO_NAME=ubuntu \
    ./docker/common
```

To run with a GPU exposed to your docker container, install the [nvidia container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html) and use the following:
```bash
docker run -it --runtime=nvidia --gpus=all streaming_md_docker_local
```

# Using a prebuilt image

We publish prebuilt images using CI at `ghcr.io`. Pull the latest image using:

```bash
docker pull ghcr.io/becksteinlab/streaming-md-docker:main-common-gpu
```

```bash
docker run -it --runtime=nvidia --gpus=all ghcr.io/becksteinlab/streaming-md-docker:main-common-gpu
```

