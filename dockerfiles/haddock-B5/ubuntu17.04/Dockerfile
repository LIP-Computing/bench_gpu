# docker build -t haddock-ubuntu17.04-b5 .
FROM ubuntu:17.04
LABEL maintainer "Mario David <mariojmdavid@gmail.com>"

# Change the NVIDIA driver version to the one in the
# the physical node
ENV NVIDIA_VER 375.26
ENV NVIDIA_DRV NVIDIA-Linux-x86_64-${NVIDIA_VER}.run
ENV LD_LIBRARY_PATH /usr/local/lib64

RUN mkdir -p /tmp/setup && \
    locale-gen en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        libboost-all-dev \
        libffi-dev \
        libfftw3-dev \
        libfftw3-double3 \
        libfftw3-long3 \
        libfftw3-single3 \
        module-init-tools \
        python-dev \
        python-pip \
        python-setuptools \
        software-properties-common \
        tar \
        time \
        wget

COPY ${NVIDIA_DRV} /tmp/setup/${NVIDIA_DRV}

RUN cd /tmp/setup && \
    ./$NVIDIA_DRV -s --no-kernel-module && \
    cd /usr/include && \
    wget http://www.lip.pt/~david/cl_include.tgz && \
    tar zxvf cl_include.tgz

RUN pip install --upgrade pip && \
    pip install Cython && \
    pip install mako && \
    pip install numpy && \
    pip install scipy && \
    pip install pyfftw && \
    pip install pyopencl && \
    cd /tmp/setup && \
    git clone https://github.com/clMathLibraries/clFFT.git && \
    git clone https://github.com/geggo/gpyfft.git && \
    git clone https://github.com/haddocking/disvis.git && \
    git clone https://github.com/haddocking/powerfit.git && \
    cd /tmp/setup/clFFT/src && \
    cmake CMakeLists.txt && \
    make install && \
    cd /tmp/setup/gpyfft && \
    python setup.py install && \
    cd /tmp/setup/disvis && \
    python setup.py install && \
    cd /tmp/setup/powerfit && \
    python setup.py install && \
    rm -f /usr/include/cl_include.tgz && \
    rm -rf /tmp/setup

WORKDIR /home
CMD ["/bin/bash"]
