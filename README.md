# Containers for IMD streaming

The following builds a container containing LAMMPS and GROMACS ready for use with the IMD v3 streaming interface.

(We also have a version of NAMD with IMDv3 streaming but NAMD's license does not allow us to include it here.)

# Building

To build the containers from source, select the directory containing
the script for the simulation engine you want to build. The "common"
directory contains a Dockerfile which will build all 3 simulation engines.

Compiler arguments for MPI and GPU acceleration can be passed through
the following build arguments as follows:
```bash
docker buildx build -t streaming_md_docker_local \
    --build-arg NAMD_OPTS="--with-cuda" \
    --build-arg GMX_OPTS="-DGMX_GPU=CUDA" \
    --build-arg LMP_OPTS="-DPKG_GPU=on -DGPU_API=cuda" common
```

You can then run the container using:

```bash
docker run -it streaming_md_docker_local

```


# Using a prebuilt image

We publish prebuilt images using CI at `ghcr.io`. Pull the latest image using:

```bash
docker pull ghcr.io/Becksteinlab/streaming-md-docker:main-Common-GPU
```

You can then run the container using:
```
docker run -it  ghcr.io/Becksteinlab/streaming-md-docker:main-Common-GPU
```

# Using a GPU

To run with a GPU exposed to your docker container, install the [nvidia container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html) and use the following

```bash
docker run -it --runtime=nvidia --gpus=all  ghcr.io/Becksteinlab/streaming-md-docker:main-Common-GPU
```
