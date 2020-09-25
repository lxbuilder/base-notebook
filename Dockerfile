# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# edited by lxbuilder

FROM lxbuilder/base-notebook:1 as bashrc_provider

USER root

RUN chown root:root /home/jovyan/.bashrc && chmod 644 /home/jovyan/.bashrc

##
FROM ubuntu:20.04

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    wget \
    ca-certificates \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/*

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    MINICONDA_VERSION=4.8.3 \
    MINICONDA_MD5=d63adf39f2c220950a063e0529d4ff74 \
    CONDA_VERSION=4.8.3 \
    PATH="/opt/conda/bin:${PATH}"

ARG PYTHON_VERSION=default

# Copy a script that we will use to correct permissions after running certain commands
# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# COPY fix-permissions /usr/local/bin/fix-permissions

# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
# RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
#     mkdir -p $CONDA_DIR && \
#     chown $NB_USER:$NB_GID $CONDA_DIR && \
#     chmod g+w /etc/passwd && \
#     fix-permissions $HOME && \
#     fix-permissions $CONDA_DIR

# USER $NB_UID
# WORKDIR $HOME

WORKDIR /tmp

RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
    mkdir /work && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_MD5} *Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes 'pip=20.2.3' && \
    conda install --quiet --yes 'notebook=6.1.4' && \
    conda remove --force -y pandoc && \
    conda clean --all -f -y && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /var/cache/*

# Install Tini
# RUN conda install --quiet --yes 'tini=0.18.0' && \
#     conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
#     conda clean --all -f -y && \
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
# RUN conda install --quiet --yes \
#     'notebook=6.1.3' && \
#     conda clean --all -f -y && \
#     npm cache clean --force && \
#     jupyter notebook --generate-config && \
#     rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
#     rm -rf /home/$NB_USER/.cache/yarn && \
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER

EXPOSE 8888

# Configure container startup
# ENTRYPOINT ["tini", "-g", "--"]
CMD ["jupyter", "notebook", "--allow-root"]

# Copy local files as late as possible to avoid cache busting
#COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
COPY --from=bashrc_provider /home/jovyan/.bashrc /root/

# Fix permissions on /etc/jupyter
# USER root
# RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
# USER $NB_UID

WORKDIR /work
