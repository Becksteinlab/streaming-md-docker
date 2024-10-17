# Containers for IMD streaming

The following builds a container containing LAMMPS, GROMACS and NAMD ready for use with the IMD v3 streaming interface.


# Building

To build the containers, use `docker build . -t streaming_md_docker_local --progress=plain` adding a docker tag if you like. You can then run the container using:

```
docker run -it streaming_md_docker_local

```


# Using a prebuilt image

We publish prebuilt images using CI at `ghcr.io`. Pull the latest image using `docker pull  ghcr.io/Becksteinlab/streaming-md-docker:main` You can then run the container using `docker run -it streaming-md-docker:main`