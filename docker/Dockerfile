# based on conda-forge linux image
FROM condaforge/linux-anvil-cuda:11.8

# add PREFIX/condabin to PATH
# RUN source /opt/docker/bin/entrypoint_source


COPY install.sh .
RUN source /opt/conda/etc/profile.d/conda.sh &&  conda activate && ./install.sh


ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
