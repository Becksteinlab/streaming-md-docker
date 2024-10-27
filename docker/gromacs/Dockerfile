# based on conda-forge linux image
FROM condaforge/linux-anvil-cuda:11.8 AS build

ARG GMX_OPTS=""

COPY . .
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create --file env.yaml
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate env && ./install_gromacs.sh "$GMX_OPTS"

# Delete the heavy environment but keep conda binaries
RUN source /opt/conda/etc/profile.d/conda.sh && conda remove -n env --all -y
RUN source /opt/conda/etc/profile.d/conda.sh && conda clean -a -y

# CUDA toolkit is massive, so use a smaller image for the runtime
FROM nvidia/cuda:11.8.0-runtime-centos7 AS runtime

COPY . .
COPY --from=build /opt/conda /opt/conda
COPY --from=build /opt/docker/bin/run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

COPY --from=build /opt/docker/bin/entrypoint /opt/docker/bin/entrypoint
COPY --from=build /opt/docker/bin/entrypoint_source /opt/docker/bin/entrypoint_source

# Create the new lightweight env
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create --file runtime_env.yaml

COPY --from=build /opt/gromacs_build /opt/gromacs_build
RUN ln -s /opt/gromacs_build/bin/gmx /bin/gmx

ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
