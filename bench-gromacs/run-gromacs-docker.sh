#!/bin/bash
TIME="/usr/bin/time"
TIME_STR="%e\ntime = %e sec"
TIME_RES="rtime.txt"
WDIR='/home'
LWDIR="/home/ubuntu/bench/test-docker"
EXEC="docker"
DOCK_NAME="gromacs"
DOCK_NVD="--device=/dev/nvidia0:/dev/nvidia0 \
          --device=/dev/nvidiactl:/dev/nvidiactl \
          --device=/dev/nvidia-uvm:/dev/nvidia-uvm"

VDIR="-v ${LWDIR}:${WDIR}"
DOCK_OPT="${DOCK_NVD} ${VDIR}"
DOCK_RUN="${EXEC} run ${DOCK_OPT} ${DOCK_NAME}"

${TIME} -f "${TIME_STR}" -o ${TIME_RES} ${DOCK_RUN} /bin/bash -c ". /usr/local/bin/GMXRC.sh; cd /home; gmx mdrun -s /home/md.tpr -ntomp 0 -gpu_id 0"
