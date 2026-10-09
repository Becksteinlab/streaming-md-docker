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

# Included builds (IMDv2 and IMDv3)

Each image contains four builds, one per code and IMD version:

| Build            | Source branch                                                                                   | Install dir            | Command       |
|------------------|-------------------------------------------------------------------------------------------------|------------------------|---------------|
| `gromacs-imdv2`  | [`vanilla-benchmarking`](https://gitlab.com/heydenlabasu/streaming-md/gromacs/-/tree/vanilla-benchmarking) (GitLab) | `/opt/gromacs-imdv2`   | `gmx-imdv2`   |
| `gromacs-imdv3`  | [`imdv3-benchmarking`](https://gitlab.com/heydenlabasu/streaming-md/gromacs/-/tree/imdv3-benchmarking) (GitLab)     | `/opt/gromacs-imdv3`   | `gmx-imdv3`   |
| `lammps-imdv2`   | [`vanilla-benchmarking`](https://github.com/Becksteinlab/lammps/tree/vanilla-benchmarking) (GitHub)                | `/opt/lammps-imdv2`    | `lmp-imdv2`   |
| `lammps-imdv3`   | [`imdv3-benchmarking`](https://github.com/Becksteinlab/lammps/tree/imdv3-benchmarking) (GitHub)                    | `/opt/lammps-imdv3`    | `lmp-imdv3`   |

The plain `gmx` and `lmp` commands point to the IMDv3 builds by default.
The branches are build arguments (`GMX_IMDV2_BRANCH`, `GMX_IMDV3_BRANCH`,
`LMP_IMDV2_BRANCH`, `LMP_IMDV3_BRANCH`) and the default can be changed with
`--build-arg DEFAULT_IMD_VERSION=imdv2`. The branches used are recorded as image labels
(e.g. `gromacs-imdv2.branch`).

Example: call a specific version by using its suffixed command (these are just
examples, any of the four commands in the table can be used the same way):

```bash
docker run -it streaming_md_docker_local gmx-imdv2 --version
docker run -it streaming_md_docker_local gmx-imdv3 --version
docker run -it streaming_md_docker_local lmp-imdv2 -h
docker run -it streaming_md_docker_local lmp-imdv3 -h
```

# Using a prebuilt image

We publish prebuilt images using CI at `ghcr.io`. Pull the latest image using:

```bash
docker pull ghcr.io/becksteinlab/streaming-md-docker:main-common-gpu
```

```bash
docker run -it --runtime=nvidia --gpus=all ghcr.io/becksteinlab/streaming-md-docker:main-common-gpu
```

