ARG RT_IMAGE=nvidia/cuda:11.8.0-runtime-centos7
# based on conda-forge linux image
FROM condaforge/linux-anvil-cuda:11.8 AS build

# Docker weirdness, need the arg again for it to exist in build stage
ARG RT_IMAGE
ARG LMP_OPTS=""
ARG GMX_OPTS=""
ARG NAMD_OPTS=""

COPY . .
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create --file env.yaml
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate env && ./install_lammps.sh "$LMP_OPTS"
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate env && ./install_gromacs.sh "$GMX_OPTS"
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate env && ./install_namd.sh "$NAMD_OPTS"

# Delete the heavy environment but keep conda binaries
RUN source /opt/conda/etc/profile.d/conda.sh && conda remove -n env --all -y
RUN source /opt/conda/etc/profile.d/conda.sh && conda clean -a -y

# CUDA toolkit is massive, so use a smaller image for the runtime
FROM ${RT_IMAGE} AS runtime

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

COPY --from=build /opt/namd-build /opt/namd-build
RUN ln -s /opt/namd-build/namd3  /bin/namd3

ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
