# docker build -t gromacs-centos7-b5 .
FROM centos:7
LABEL maintainer "Mario David <mariojmdavid@gmail.com>"

# Change the NVIDIA driver version to the one in the
# the physical node
ENV NVIDIA_VER 375.26
ENV NVIDIA_DRV NVIDIA-Linux-x86_64-${NVIDIA_VER}.run
ENV CUDA_RUN cuda-linux64-rel-8.0.61-21551265.run
ENV GROMACS_DIR /usr/local/gromacs
ENV GMXBIN $GROMACS_DIR/bin
ENV GMXDATA $GROMACS_DIR/share/gromacs
ENV GMXLDLIB $GROMACS_DIR/lib
ENV GMXMAN $GROMACS_DIR/share/man
ENV PATH $GMXBIN:/usr/local/cuda-8.0/bin:$PATH
ENV LD_LIBRARY_PATH $GMXLDLIB:/usr/local/cuda-8.0/lib64:/usr/local/lib64
ENV MANPATH $GMXMAN:$MANPATH
ENV PKG_CONFIG_PATH $GMXLDLIB/pkgconfig:$PKG_CONFIG_PATH
ENV CXX "/usr/bin/g++"

RUN mkdir -p /tmp/setup && \
    yum -y install epel-release && \
    yum -y update

RUN yum -y install \
        atlas-devel \
        blas-devel \
        boost-devel.x86_64 \
        boost-static.x86_64 \
        cmake.x86_64 \
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
        sudo \
        tar \
        time \
        wget

COPY ${NVIDIA_DRV} /tmp/setup/${NVIDIA_DRV}
COPY ${CUDA_RUN} /tmp/setup/${CUDA_RUN}

RUN cd /tmp/setup && \
    ./${NVIDIA_DRV} -s --no-kernel-module && \
    ./${CUDA_RUN} -noprompt

RUN wget http://ftp.gromacs.org/pub/gromacs/gromacs-2016.3.tar.gz && \
    tar zxvf gromacs-2016.3.tar.gz && \
    cd gromacs-2016.3 && \
    mkdir build && \
    cd build && \
    cmake .. -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=on && \
    make && \
    make install

RUN rm -rf /tmp/setup

WORKDIR /home
CMD ["/bin/bash"]
