# Containers for IMD streaming

The following builds a container containing LAMMPS, GROMACS and NAMD ready for use with the IMD v3 streaming interface.


# Building

To build the containers, use the below:

```bash
docker build . -t streaming_md_docker_local --progress=plain
```

You can then run the container using:

```bash
docker run -it streaming_md_docker_local

```


# Using a prebuilt image

We publish prebuilt images using CI at `ghcr.io`. Pull the latest image using:

```bash
docker pull ghcr.io/becksteinlab/streaming-md-docker:main
```

You can then run the container using:
```
docker run -it streaming-md-docker:main
```

# Using a GPU

To run with a GPU exposed to your docker container, install the [nvidia container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html) and use the following

```bash
docker run -it --runtime=nvidia --gpus=all docker pull ghcr.io/becksteinlab/streaming-md-docker:main
```
