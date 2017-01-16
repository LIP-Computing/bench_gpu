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
# Run docker or udocker
EXEC="docker"
#EXEC="udocker.py"

####### This is for containers Centos7
#MACH=Dock-C7-QK2200
#MACH=Dock-C7-QK5200
#MACH=Dock-C7-TK40

#MACH=UDock-C7-QK2200
#MACH=UDock-C7-QK5200
#MACH=UDock-C7-TK40

# Docker container name
#DOCK_NAME=haddock-centos7-build2

###############################
####### This is for containers Ubuntu16.04
#MACH=Dock-U16-QK2200
#MACH=Dock-U16-QK5200
MACH=Dock-U16-TK40

#MACH=UDock-U16-QK2200
#MACH=UDock-U16-QK5200
#MACH=UDock-U16-TK40

# Docker container name
DOCK_NAME=haddock-ubuntu16.04-build2

# Variables to change by the user, should turn into argument to the script
CASE="GroEL-GroES"
#CASE="RsgA-ribosome"

# Number of runs of each type for statistical purposes
NRUNS=10

#############################################################
# From here on everyhting is fixed
LWDIR=`pwd`   # Local/physical directory
WDIR='/home'  # Working dir inside the docker
TIME="/usr/bin/time"
TIME_STR="%e\ntime = %e sec\nMem = %M kB"
DOCK_NVD="--device=/dev/nvidia0:/dev/nvidia0 \
          --device=/dev/nvidiactl:/dev/nvidiactl \
          --device=/dev/nvidia-uvm:/dev/nvidia-uvm"
VDIR="-v ${LWDIR}:${WDIR}"

DOCK_OPT="${VDIR}"

if [ ${EXEC} = "docker" ]
then
  DOCK_OPT="${DOCK_NVD} ${VDIR}"
fi

#TYPE is either -g for GPU or -p NN for CPU NN processes
TAG_TYPE="GPU"

CASEDIR=${CASE}
if [ ${CASE} = "GroEL-GroES" ]
then
  PDBF=GroES_1gru.pdb
  MAPF=1046.map
  RESOL=23.0
fi

if [ ${CASE} = "RsgA-ribosome" ]
then
  PDBF=4adv_V.pdb
  MAPF=2017.map
  RESOL=13.3
fi

ANG="4.71"
PWRFIT_PAR="-a ${ANG} -l"

INPUT_DIR=${WDIR}/${CASEDIR}
PDB=${INPUT_DIR}/${PDBF}
MAP=${INPUT_DIR}/${MAPF}
RESOUT=${WDIR}/res-${CASE}
LRESOUT=${LWDIR}/res-${CASE}
LTIMEOUT=${LWDIR}/${MACH}/time-${CASE}
TIMEOUT=${WDIR}/${MACH}/time-${CASE}

mkdir -p ${LRESOUT}
mkdir -p ${LTIMEOUT}

echo "-> Input files: ${PDB} ${MAP} Resolution: ${RESOL}"

### Run on the GPUs
DOCK_RUN="${EXEC} run ${DOCK_OPT} ${DOCK_NAME}"

for i in `seq -w ${NRUNS}`
do
  TAG="ang-${ANG}-type-${TAG_TYPE}-n-${i}"
  TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
  OUT_DIR=${RESOUT}/"res_${TAG}"
  TYPE="-g"
  echo "-------------------------------------"
  echo "-> Params: angle = ${ANG} -l = Use the Laplace pre-filter density data"
  echo "-> TYPE = ${TAG_TYPE}"
  echo "-> Run num: ${i}"
  echo
  echo "-> Executing:"
  echo     "${DOCK_RUN} ${TIME} -f "${TIME_STR}" -o ${TIME_RES} powerfit ${MAP} ${RESOL} ${PDB} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}"
  echo
  ${DOCK_RUN} ${TIME} -f "${TIME_STR}" -o ${TIME_RES} powerfit ${MAP} ${RESOL} ${PDB} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}
  rm -rf ${LRESOUT}/"res_${TAG}"
done

# udocker.py rm `udocker.py ps|cut -d" " -f 1|grep -v CONTAINER`
