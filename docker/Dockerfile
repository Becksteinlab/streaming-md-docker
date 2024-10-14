# based on conda-forge linux image
FROM condaforge/linux-anvil-cuda:11.8


COPY install.sh .
COPY env.yml .
RUN source /opt/conda/etc/profile.d/conda.sh && conda env create -f env.yml
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate && ./install_lammps.sh
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate && ./install_gromacs.sh
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate && ./install_namd.sh


ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
