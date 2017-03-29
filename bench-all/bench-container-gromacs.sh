#!/bin/bash

#
# bench-disvis.sh: benchmark of disvis run on GPUs
# Execution on physical hosts or VMs
#
# Copyright (C) LIP and IndigoDataCloud EU project
# Author: Mario David <david@lip.pt>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Number of runs of each type for statistical purposes
NRUNS=20
NVIDIA=QK5200
#NVIDIA=TK40
ROOT_DIR=/cloud/root
OUT_DIR=${ROOT_DIR}/bench-run5

ROOT_INPUT_DIR=${ROOT_DIR}/bench-input
R_OUT_DIR=${OUT_DIR}/results
T_OUT_DIR=${OUT_DIR}/time
PATH=${ROOT_DIR}/udocker:${PATH}
TIME="/usr/bin/time"
TIME_STR="%e"
DOCK_NVD="--device=/dev/nvidia0:/dev/nvidia0 \
          --device=/dev/nvidiactl:/dev/nvidiactl \
          --device=/dev/nvidia-uvm:/dev/nvidia-uvm"
CONT_NAME=gromacs

for OS in "C7" "U16"
do

    # Gromacs
    if [ ${OS} = "C7" ]
    then
        DOCK_NAME=gromacs-centos7-b5
    fi

    if [ ${OS} = "U16" ]
    then
        DOCK_NAME=gromacs-ubuntu16.04-b5
    fi

    for EXEC in "docker" "udocker"
    do

        VDIR="-v ${ROOT_INPUT_DIR}:/home/input -v ${R_OUT_DIR}:/home/output"
        DOCK_OPT="${VDIR}"

        if [ ${EXEC} = "docker" ]
        then
            MACH="Dock-${OS}-${NVIDIA}"
            DOCK_OPT="${DOCK_NVD} ${VDIR}"
            DOCK_RUN="${EXEC} run ${DOCK_OPT} --name ${CONT_NAME} ${DOCK_NAME}"
        fi

        if [ ${EXEC} = "udocker" ]
        then
            MACH="UDock-${OS}-${NVIDIA}"
            ${EXEC} create ${DOCK_OPT} --name=${CONT_NAME} ${DOCK_NAME}
            DOCK_RUN="${EXEC} run ${CONT_NAME}"
        fi

        CASE="gromacs"
        RESOUT=${R_OUT_DIR}/${MACH}/res-${CASE}
        TIMEOUT=${T_OUT_DIR}/${MACH}/time-${CASE}
        INPUT_DIR=/home/input/${CASE}
        OUTPUT_DIR=/home/output/${MACH}/res-${CASE}
        INFILE=${INPUT_DIR}/md.tpr

        mkdir -p ${RESOUT}
        mkdir -p ${TIMEOUT}
        echo "-> Input files: ${PDB1} ${PDB2} ${REST}"
        for i in `seq -w ${NRUNS}`
        do
          TAG="n-${i}"
          TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
          OUT_DIR=${RESOUT}/"res_${TAG}"
          echo "-------------------------------------"
          echo "-> Run num: ${i}"
          echo
          echo "-> Executing:"
          echo     "${TIME} -f "${TIME_STR}" -o ${TIME_RES} ${DOCK_RUN} gmx mdrun -s ${INFILE} -ntomp 8 -gpu_id 0"
          echo
          ${TIME} -f "${TIME_STR}" -o ${TIME_RES} ${DOCK_RUN} gmx mdrun -s ${INFILE} -ntomp 8 -gpu_id 0
          if [ ${EXEC} = "docker" ]
          then
            docker rm ${CONT_NAME}
          fi
        done
        udocker rm ${CONT_NAME}
    done
done
