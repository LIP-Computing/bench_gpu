#!/bin/bash

#
# bench-powerfit.sh: benchmark of powerfit run on GPUs
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
CASE="GroEL-GroES"
#CASE="RsgA-ribosome"

# Number of runs of each type for statistical purposes
NRUNS=3

#############################################################
# From here on everyhting is fixed
WDIR=`pwd`
TIME="/usr/bin/time"
TIME_STR="time = %e sec\nMem = %M kB"

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
TIMEOUT=${WDIR}/time-${CASE}

mkdir -p ${RESOUT}
mkdir -p ${TIMEOUT}

echo "-> Input files: ${PDB} ${MAP} Resolution: ${RESOL}"

for i in `seq ${NRUNS}`
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
  echo "-> Executing powerfit ${PDB} ${MAP} ${RESOL} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}"
  echo
  #echo "${TIME} -f ${TIME_STR} -o ${TIME_RES} powerfit ${PDB} ${MAP} ${RESOL} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}}"
  ${TIME} -f "${TIME_STR}" -o ${TIME_RES} powerfit ${MAP} ${RESOL} ${PDB} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}
done
