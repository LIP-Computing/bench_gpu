# docker build -t gromacs-centos7-b5 .
FROM centos:7
LABEL maintainer "Mario David <mariojmdavid@gmail.com>"

# Change the NVIDIA driver version to the one in the
# the physical node
ENV NVIDIA_VER 375.26
ENV NVIDIA_DRV NVIDIA-Linux-x86_64-${NVIDIA_VER}.run
ENV LD_LIBRARY_PATH /usr/local/lib64

RUN mkdir -p /tmp/setup && \
    yum -y install epel-release && \
    yum -y update

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
        time \
        wget

COPY ${NVIDIA_DRV} /tmp/setup/${NVIDIA_DRV}

RUN cd /tmp/setup && \
    ./${NVIDIA_DRV} -s --no-kernel-module

WORKDIR /home
CMD ["/bin/bash"]
