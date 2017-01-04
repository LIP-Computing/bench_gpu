# docker-opencl
Dockerfile: Ubuntu 14.04 (LTS) NVIDIA driver v361.42 + (py)opencl

## Pre-conditions

The host machine **has** to have the same driver version of the one which will be
installed in the docker image, check here:

* http://www.nvidia.com/Download/index.aspx?lang=en-us

The Dockerfile sets the NVIDIA driver version to: 361.42, if you have a different
version on the host machine adjust the ENV NVIDIA_VER accordingly.

In case the NVIDIA driver is not online or you have it locally uncomment
the following line:

* COPY $NVIDIA_DRV /tmp/setup/$NVIDIA_DRV
* And remove the line "wget $NVIDIA_DOWNLOAD"

## Install

* docker build -t pyopencl .

## Run

The command runs an interactive bash shell

```
docker run \
    -it
    --device=/dev/nvidia0:/dev/nvidia0 \
    --device=/dev/nvidiactl:/dev/nvidiactl \
    --device=/dev/nvidia-uvm:/dev/nvidia-uvm \
    pyopencl
```




