#!/bin/bash
. /usr/local/gromacs/bin/GMXRC.bash

TIME="/usr/bin/time"
TIME_STR="%e\ntime = %e sec"
TIME_RES="rtime.txt"

${TIME} -f "${TIME_STR}" -o ${TIME_RES} gmx mdrun -s md.tpr -ntomp 0 -gpu_id 0
