FROM python:3.8-slim

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#USER root

#COPY util/* /usr/local/bin/

# RUN apt-get update \
#     && apt-get install -yq --no-install-recommends \
#        locales \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
#ENV DEBIAN_FRONTEND noninteractive
# RUN apk add --no-cache \
#     wget \
#     bzip2 \
#     ca-certificates \
#     sudo \
#     bash 

# RUN \
#   apk add --no-cache binutils \
#     bash \
#     bzip2 \
#     curl \
#     file \
#     gcc \
#     g++ \
#     git \
#     libressl \
#     libsodium-dev \
#     make \
#     openssh-client \
#     patch \
#     readline-dev \
#     tar \
#     tini \
#     wget && \
#   echo "### Install specific version of zeromq from source" && \
#   min-package https://archive.org/download/zeromq_4.0.4/zeromq-4.0.4.tar.gz && \
#   ln -s /usr/local/lib/libzmq.so.3 /usr/local/lib/libzmq.so.4 && \
#   strip --strip-unneeded --strip-debug /usr/local/bin/curve_keygen && \
#   echo "### Alpine compatibility patch for various packages" && \
#   if [ ! -f /usr/include/xlocale.h ]; then echo '#include <locale.h>' > /usr/include/xlocale.h; fi && \
#   echo "### Cleanup unneeded files" && \
#   clean-terminfo ; \
#   rm /usr/local/share/man/*/zmq* ; \
#   rm -rf /usr/include/c++/*/java ; \
#   rm -rf /usr/include/c++/*/javax ; \
#   rm -rf /usr/include/c++/*/gnu/awt ; \
#   rm -rf /usr/include/c++/*/gnu/classpath ; \
#   rm -rf /usr/include/c++/*/gnu/gcj ; \
#   rm -rf /usr/include/c++/*/gnu/java ; \
#   rm -rf /usr/include/c++/*/gnu/javax ; \
#   rm /usr/libexec/gcc/x86_64-alpine-linux-musl/*/cc1obj ; \
#   rm /usr/bin/gcov* ; \
#   rm /usr/bin/gprof ; \
#   rm -rf /usr/bin/*gcj

#RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME=/home/$NB_USER

# Copy a script that we will use to correct permissions after running certain commands
#RUN chmod a+rx /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
# RUN sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#     sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
#RUN  useradd -m -N -s /bin/bash -u $NB_UID $NB_USER && \
    # chmod g+w /etc/passwd && \
    # ls -lha && \
    # fix-permissions $HOME
    # fix-permissions $CONDA_DIR

# USER $NB_UID
# WORKDIR $HOME
#ARG PYTHON_VERSION=default

# Setup work directory for backward-compatibility
# RUN mkdir /home/$NB_USER/work && \
#     fix-permissions /home/$NB_USER

# Install conda as jovyan and check the md5 sum provided on the download site
#ENV MINICONDA_VERSION=4.8.3 \
#   MINICONDA_MD5=d63adf39f2c220950a063e0529d4ff74 \
#    CONDA_VERSION=4.8.3

#WORKDIR /tmp
#RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    # echo "${MINICONDA_MD5} *Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    # /bin/bash Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    # rm Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    # echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    # conda config --system --prepend channels conda-forge && \
    # conda config --system --set auto_update_conda false && \
    # conda config --system --set show_channel_urls true && \
    # conda config --system --set channel_priority strict && \
    # if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    # conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    # conda install --quiet --yes conda && \
    # conda install --quiet --yes pip && \
    # conda update --all --quiet --yes && \
    # conda clean --all -f -y && \
    # rm -rf /home/$NB_USER/.cache/yarn && \
    # fix-permissions $CONDA_DIR && \
    # fix-permissions /home/$NB_USER

# Install Tini
#RUN conda install --quiet --yes 'tini=0.18.0' && \
    # conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    # conda clean --all -f -y && \
    # fix-permissions $CONDA_DIR && \
    # fix-permissions /home/$NB_USER

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
#RUN conda install --quiet --yes \
    # 'notebook=6.1.3' \
    # 'jupyterhub=1.1.0' \
    # 'jupyterlab=2.2.5' && \
    # conda clean --all -f -y && \
    # npm cache clean --force && \
    # jupyter notebook --generate-config && \
    # rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    # rm -rf /home/$NB_USER/.cache/yarn && \
    # fix-permissions $CONDA_DIR && \
    # fix-permissions /home/$NB_USER

EXPOSE 8888

# Configure container startup
#ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Copy local files as late as possible to avoid cache busting
COPY start.sh start-notebook.sh start-singleuser.sh fix-permissions /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
#COPY fix-permissions /usr/local/bin/fix-permissions

# Fix permissions on /etc/jupyter as root
#USER root
RUN pip install --no-cache-dir notebook && \
	fix-permissions /etc/jupyter/ && \
	chmod a+rx /usr/local/bin/fix-permissions && \
	useradd -m -N -s /bin/bash -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME
    #su - $NB_USER -c "mkdir /home/$NB_USER/work"

#RUN echo $NB_USER && su - $NB_USER -c bash -c "/usr/local/bin/fix-permissions /home/jovyan"
# RUN echo $NB_USER && su - $NB_USER -c "echo /home/$NB_USER"

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
	fix-permissions /home/$NB_USER


WORKDIR $HOME
