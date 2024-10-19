# based on conda-forge linux image
FROM condaforge/linux-anvil-cuda:11.8

ARG GMX_OPTS=""

COPY .. .
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create --file env.yaml
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate env && ./install_gromacs.sh $GMX_OPTS



ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
