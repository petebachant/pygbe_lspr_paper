# Dockerfile for PyGBe
# --------------------
# To build the image:
# `nvidia-docker build --tag=pygbe:master .`
# To run a container:
# `nvidia-docker run --name=pygbe -it pygbe:master /bin/bash`
# If running a newer version of nvdidia-docker to run container
# `docker run --runtime=nvidia --name=pygbe -it pygbe:master /bin/bash`
# To access the software:
# Once in the container, pygbe can be found in `/opt/pygbe/pygbe-master`
# To stop the container:
# `nvidia-docker stop pygbe`
# To restart the container:
# `nvidia-docker restart pygbe`
# To access the container once you exited
# `nvidia-docker exec -it pygbe /bin/bash`
# To delete the container:
# `docker rm pygbe`

FROM cogniac/nvidia-cuda:8.0-cudnn7-devel-ubuntu16.04-20190822

# Install basic requirements
RUN apt-get update && \
    apt-get install -y wget unzip vim tmux bzip2 tar make ctags

# Install Miniconda.
RUN FILENAME=Miniconda3-4.3.21-Linux-x86_64.sh && \
    wget -q https://repo.anaconda.com/miniconda/${FILENAME} -P /tmp && \
    bash /tmp/${FILENAME} -b -p /opt/miniconda && \
    export PATH=/opt/miniconda/bin:$PATH && \
    rm -f /tmp/${FILENAME}

ENV PATH="/opt/miniconda/bin:$PATH"

# Install required packages.
RUN conda install -yq \
    numpy=1.13.1 \
    scipy=0.19.1 \
    matplotlib=2.0.2 \
    swig=3.0.10 \
    requests=2.14.2 \
    pytest=3

RUN conda update pip -yq

RUN pip install --no-cache-dir -q mako==1.1.6 clint==0.5.1 pytools==2018.5.2

# Install PyCUDA.
RUN VERSION=2017.1.1 && \
    TARBALL=pycuda-${VERSION}.tar.gz && \
    wget -q https://pypi.python.org/packages/b3/30/9e1c0a4c10e90b4c59ca7aa3c518e96f37aabcac73ffe6b5d9658f6ef843/${TARBALL} -P /tmp && \
    PYCUDA_DIR=/opt/pycuda/${VERSION} && \
    mkdir -p ${PYCUDA_DIR} && \
    tar -xzf /tmp/${TARBALL} -C ${PYCUDA_DIR} --strip-components=1 && \
    rm -f /tmp/${TARBALL} && \
    cd ${PYCUDA_DIR} && \
    python configure.py --cuda-root=/usr/local/cuda-8.0 && \
    make -j"$(nproc)" && \
    make install

# Install PyGBe
COPY pygbe/pygbe /opt/pygbe/pygbe
COPY pygbe/setup.py /opt/pygbe
COPY pygbe/setup.cfg /opt/pygbe
COPY pygbe/versioneer.py /opt/pygbe
RUN cd /opt/pygbe && python setup.py install clean
