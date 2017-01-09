# docker build -t disvis-centos7-build1 .

FROM centos:7

MAINTAINER Mario David <mariojmdavid@gmail.com>

# Change the NVIDIA driver version to the one in the
# the physical node
ENV NVIDIA_VER 367.48
ENV NVIDIA_DRV NVIDIA-Linux-x86_64-$NVIDIA_VER.run
ENV LD_LIBRARY_PATH /usr/local/lib64

# Disvis or Powerfit, uncomment which one you want
ENV HADD disvis
# ENV HADD powerfit

RUN mkdir -p /tmp/setup
RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install \
        atlas-devel \
        blas-devel \
        boost-devel.x86_64 \
        boost-static.x86_64 \
        cmake.x86_64 \
        fftw.x86_64 \
        fftw-devel.x86_64 \
        fftw-libs.x86_64 \
        fftw-libs-double.x86_64 \
        fftw-libs-long.x86_64 \
        fftw-libs-single.x86_64 \
        gcc.x86_64 \
        gcc-c++.x86_64 \
        gcc-gfortran.x86_64 \
        git \
        kernel-devel \
        lapack-devel \
        libffi-devel.x86_64 \
        make \
        openssl-devel \
        perl \
        python-devel \
        python-pip \
        python-setuptools \
        tar \
        wget

# In case the NVIDIA driver is not online or you have it
# locally uncomment the following line and remove
# the line "wget $NVIDIA_DOWNLOAD"
COPY $NVIDIA_DRV /tmp/setup/$NVIDIA_DRV

RUN cd /tmp/setup && \
    ./$NVIDIA_DRV -s --no-kernel-module

RUN cd /usr/include && \
    wget http://www.lip.pt/~david/cl_include.tgz && \
    tar zxvf cl_include.tgz

RUN pip install --upgrade pip && \
    pip install Cython && \
    pip install mako

RUN pip install numpy
RUN pip install scipy
RUN pip install pyfftw
RUN pip install pyopencl

RUN cd /tmp/setup && \
    git clone https://github.com/clMathLibraries/clFFT.git && \
    git clone https://github.com/geggo/gpyfft.git && \
    git clone https://github.com/haddocking/${HADD}.git

RUN cd /tmp/setup/clFFT/src && \
    cmake CMakeLists.txt && \
    make install

RUN cd /tmp/setup/gpyfft && \
    python setup.py install

RUN cd /tmp/setup/${HADD} && \
    python setup.py install && \
    rm -f /usr/include/cl_include.tgz && \
    rm -rf /tmp/setup

CMD ["/bin/bash"]
