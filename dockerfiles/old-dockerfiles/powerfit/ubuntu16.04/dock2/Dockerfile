# docker build -t pyopencl .

FROM ubuntu:14.04

MAINTAINER Mario David <mariojmdavid@gmail.com>

# Change the NVIDIA driver version to the one in the
# the physical node
ENV NVIDIA_VER 361.42
ENV NVIDIA_DOWNLOAD http://us.download.nvidia.com/XFree86/Linux-x86_64/$NVIDIA_VER/NVIDIA-Linux-x86_64-$NVIDIA_VER.run
ENV NVIDIA_DRV NVIDIA-Linux-x86_64-$NVIDIA_VER.run

RUN mkdir -p /tmp/setup && \
    locale-gen en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        cython \
        git \
        python-dev \
        python-pip \
        software-properties-common \
        tar \
        wget

# In case the NVIDIA driver is not online or you have it
# locally uncomment the following line and remove
# the line "wget $NVIDIA_DOWNLOAD"
#COPY $NVIDIA_DRV /tmp/setup/$NVIDIA_DRV

RUN cd /tmp/setup && \
    wget $NVIDIA_DOWNLOAD && \
    chmod 700 $NVIDIA_DRV && \
    ./$NVIDIA_DRV -s --no-kernel-module && \
    cd /usr/include && \
    wget http://www.lip.pt/~david/cl_include.tgz && \
    tar zxvf cl_include.tgz && \
    apt-get install -y --no-install-recommends \
        libffi-dev \
        libfftw3-dev \
        libfftw3-double3 \
        libfftw3-long3 \
        libfftw3-single3 && \
    pip install --upgrade pip && \
    pip install mako && \
    pip install numpy && \
    pip install	pyfftw && \
    pip install	pyopencl==2015.1 && \
    cd /tmp/setup && \
    git clone https://github.com/clMathLibraries/clFFT.git && \
    git clone https://github.com/geggo/gpyfft.git && \
    cd /tmp/setup/clFFT/src && \
    cmake CMakeLists.txt && \
    make install && \
    cd /tmp/setup/gpyfft && \
    python setup.py install && \
    rm -f /usr/include/cl_include.tgz && \
    rm -rf /tmp/setup

CMD ["/bin/bash"]
