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

# Variables to change by the user, should turn into argument to the script
CASE="PRE5-PUP2-complex"
#CASE="RNA-polymerase-II"

# Number of runs of each type for statistical purposes
NRUNS=1

#############################################################
# From here on everyhting is fixed
LWDIR=`pwd`   # Local/physical directory
WDIR='/home'  # Working dir inside the docker
TIME="/usr/bin/time"
TIME_STR="time = %e sec\nMem = %M kB"
DOCK_NVD="--device=/dev/nvidia0:/dev/nvidia0 \
          --device=/dev/nvidiactl:/dev/nvidiactl \
          --device=/dev/nvidia-uvm:/dev/nvidia-uvm"
VDIR="-v ${LWDIR}:${WDIR}"
DOCK_OPT="${DOCK_NVD} ${VDIR}"

#TYPE is either -g for GPU or -p NN for CPU NN processes
TAG_TYPE="GPU"

if [ ${CASE} = "PRE5-PUP2-complex" ]
then
  PDBF1=O14250.pdb
  PDBF2=Q9UT97.pdb
  CASEDIR=${CASE}
fi

if [ ${CASE} = "RNA-polymerase-II" ]
then
  PDBF1=1wcm_A.pdb
  PDBF2=1wcm_E.pdb
  CASEDIR=${CASE}/A-E
fi

INPUT_DIR=${WDIR}/${CASEDIR}
PDB1=${INPUT_DIR}/${PDBF1}
PDB2=${INPUT_DIR}/${PDBF2}
REST=${INPUT_DIR}/restraints.dat
RESOUT=${WDIR}/res-docker-${CASE}
LRESOUT=${LWDIR}/res-docker-${CASE}
TIMEOUT=${LWDIR}/time-docker-${CASE}

mkdir -p ${LRESOUT}
mkdir -p ${TIMEOUT}

echo "-> Input files: ${PDB1} ${PDB2} ${REST}"

### Run on the GPUs
DOCK_RUN="docker run ${DOCK_OPT} opencl_disvis /bin/sh -c"

for i in `seq ${NRUNS}`
do
  for ANG in "10.0"
  do
    for VS in "2"
    do
      TAG="ang-${ANG}-vs-${VS}-type-${TAG_TYPE}-n-${i}"
      TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
      OUT_DIR=${RESOUT}/"res_${TAG}"
      DISVIS_PAR="-a ${ANG} -vs ${VS}"
      TYPE="-g"
      echo "-------------------------------------"
      echo "-> Params: angle = ${ANG}  voxel spacing = ${VS}"
      echo "-> TYPE = ${TAG_TYPE}"
      echo "-> Run num: ${i}"
      echo
      echo "-> Executing disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
      echo
      #echo "${TIME} -f ${TIME_STR} -o ${TIME_RES} ${DOCK_RUN} \"export LD_LIBRARY_PATH=/usr/local/lib64; disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}\""
      ${TIME} -f "${TIME_STR}" -o ${TIME_RES} ${DOCK_RUN} "export LD_LIBRARY_PATH=/usr/local/lib64; disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
    done
  done
done
