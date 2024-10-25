# based on conda-forge linux image
FROM condaforge/linux-anvil-cuda:11.8

ARG LMP_OPTS=""
ARG GMX_OPTS=""
ARG NAMD_OPTS=""

COPY . .
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create --file env.yaml
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate env && ./install_lammps.sh $LMP_OPTS
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate env && ./install_gromacs.sh $GMX_OPTS
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate env && ./install_namd.sh $NAMD_OPTS

# Remove source code, only keeping binaries
RUN rm -rf /opt/lammps /opt/gromacs /opt/namd-3.0

# Don't need development tools in the final image
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate env && conda remove cudatoolkit -y
# Removes ~2GB of conda cache
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate env && conda clean --all -y

ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
