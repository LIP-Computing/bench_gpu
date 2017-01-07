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

# Docker container name
DOCK_NAME=powerfit-ubuntu16.04-build1

EXEC=udocker.py

# Variables to change by the user, should turn into argument to the script
CASE="GroEL-GroES"
#CASE="RsgA-ribosome"

# Number of runs of each type for statistical purposes
NRUNS=1

#############################################################
# From here on everyhting is fixed
LWDIR=`pwd`   # Local/physical directory
WDIR='/home'  # Working dir inside the docker
TIME="/usr/bin/time"
TIME_STR="%e\ntime = %e sec\nMem = %M kB"
VDIR="-v ${LWDIR}:${WDIR}"
DOCK_OPT="${VDIR}"

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
RESOUT=${WDIR}/${DOCK_NAME}/res-docker-${CASE}
LRESOUT=${LWDIR}/${DOCK_NAME}/res-docker-${CASE}
TIMEOUT=${LWDIR}/${DOCK_NAME}/time-docker-${CASE}

mkdir -p ${LRESOUT}
mkdir -p ${TIMEOUT}

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
  echo     "${TIME} -f ${TIME_STR} -o ${TIME_RES} ${DOCK_RUN} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
  echo
  ${TIME} -f "${TIME_STR}" -o ${TIME_RES} ${DOCK_RUN} powerfit ${MAP} ${RESOL} ${PDB} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}
done
