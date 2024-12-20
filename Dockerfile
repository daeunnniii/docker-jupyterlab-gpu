ARG TF_VERSION
FROM tensorflow/tensorflow:${TF_VERSION}-gpu
LABEL maintainer="daeunnniii <storyda47@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN sed -i 's/archive.ubuntu.com/ftp.kaist.ac.kr/g' /etc/apt/sources.list && \
    apt-get update && apt-get upgrade -y
RUN apt-get install -y apt-utils sudo locales debconf apt wget git curl \
    vim net-tools build-essential htop && \
    rm -rf /var/lib/apt/lists/*

# Add Korean locale
RUN locale-gen en_US.UTF-8 ko_KR.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:ko_KR

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 \
 && echo "LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4" >> /etc/profile

# Setting up environment
ARG USERNAME
ARG UID
ENV CONDA_DIR=/opt/conda \
    USERNAME=$USERNAME \
    UID=$UID
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$USERNAME

# Add users and grant sudo privileges
RUN groupadd -g $UID $USERNAME && \
    useradd -m -s /bin/bash -p $USERNAME -g $USERNAME -N -u $UID $USERNAME && \
    adduser $USERNAME sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

RUN mkdir -p $CONDA_DIR && \
    chown -R $USERNAME.$USERNAME $CONDA_DIR

# Changing user
USER $USERNAME
WORKDIR $HOME

# Installing miniconda
ARG MINICONDA_VERSION
RUN wget --quiet -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    bash miniconda.sh -u -b -p $CONDA_DIR && \
    rm miniconda.sh

# Installing Jupyterlab
ARG PYTHON_VERSION
RUN conda install -y libgcc tini python=${PYTHON_VERSION} && \
   conda config --system --prepend channels conda-forge && \
   conda update --all -y && \
   conda init bash

# Install jupyterlab ###########################################################################################
RUN conda install -c conda-forge --yes notebook jupyterhub jupyterlab jupyter_bokeh

# Install tensorflow ###########################################################################################
ARG TF_VERSION
RUN pip install --no-cache-dir tensorrt nvidia-pyindex nvidia-tensorrt tensorrt-dispatch tensorrt-lean tensorflow==${TF_VERSION} tensorflow-addons streamlit tensorflow-datasets tensorflow-hub tensorflow-probability

# Install pytorch ##############################################################################################
RUN pip install torch torchvision torchaudio

# Installing pip packages
COPY requirements-pip.txt /tmp/requirements-pip.txt
RUN pip install --no-cache-dir -r /tmp/requirements-pip.txt

# Installing conda packages
COPY requirements-conda.yml /tmp/requirements-conda.yml
RUN conda env update --name base -f /tmp/requirements-conda.yml && conda clean -afy

RUN jupyter lab --generate-config && \
 echo "c.NotebookApp.terminado_settings={'shell_command': ['/bin/bash']}" >> /home/${USERNAME}/.jupyter/jupyter_lab_config.py && \
 jupyter lab build

EXPOSE 8888
VOLUME /notebook
WORKDIR /notebook