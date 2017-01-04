# docker build -t disvis-ubuntu16.04-build1 .

FROM ubuntu:16.04

MAINTAINER Mario David <mariojmdavid@gmail.com>

# Change the NVIDIA driver version to the one in the
# the physical node
ENV NVIDIA_VER 367.48
ENV NVIDIA_DRV NVIDIA-Linux-x86_64-$NVIDIA_VER.run

RUN mkdir -p /tmp/setup && \
    locale-gen en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        cython \
        git \
        libffi-dev \
        libfftw3-dev \
        libfftw3-double3 \
        libfftw3-long3 \
        libfftw3-single3 \
        python-dev \
        python-pip \
        software-properties-common \
        tar \
        wget

# In case the NVIDIA driver is not online or you have it
# locally uncomment the following line and remove
# the line "wget $NVIDIA_DOWNLOAD"
COPY $NVIDIA_DRV /tmp/setup/$NVIDIA_DRV

RUN cd /tmp/setup && \
    ./$NVIDIA_DRV -s --no-kernel-module && \
    cd /usr/include && \
    wget http://www.lip.pt/~david/cl_include.tgz && \
    tar zxvf cl_include.tgz && \
    pip install --upgrade pip && \
    pip install mako && \
    pip install numpy && \
    pip install	pyfftw && \
    pip install	pyopencl && \
    cd /tmp/setup && \
    git clone https://github.com/clMathLibraries/clFFT.git && \
    git clone https://github.com/geggo/gpyfft.git && \
    git clone https://github.com/haddocking/disvis.git && \
    cd /tmp/setup/clFFT/src && \
    cmake CMakeLists.txt && \
    make install && \
    cd /tmp/setup/gpyfft && \
    python setup.py install && \
    cd /tmp/setup/disvis && \
    python setup.py install && \
    rm -f /usr/include/cl_include.tgz && \
    rm -rf /tmp/setup

CMD ["/bin/bash"]
